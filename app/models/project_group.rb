# == Schema Information
#
# Table name: timeline_entries
#
#  actual_end_date         :date
#  agent_id                :integer
#  created_at              :datetime         not null
#  date_change_count       :integer          default(0), not null
#  finalized_at            :datetime
#  id                      :integer          not null, primary key
#  is_finalized            :boolean
#  old_duration_days       :integer          default(0)
#  old_start_date          :date
#  parent_id               :integer
#  project_id              :integer
#  project_type            :string
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id                     (agent_id)
#  index_timeline_entries_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
#  fk_rails_fe366670d0  (schedule_parent_id => timeline_entries.id)
#

require 'chronic'
class ProjectGroup < TimelineEntry
  class DestroyWithChildrenError < StandardError; end
  class MultipleRootError < StandardError; end

  # Causing migration problems. Is this really necessary? ~Fuzzy
  # validate :has_summary

  before_create :ensure_single_root

  # Prepend required to work with has_closure_tree,
  # otherwise children are deleted before we even get here.
  before_destroy :validate_no_children, prepend: true

  def summary_or_none
    summary.blank? ? "[#{I18n.t("none")}]" : summary.to_s
  end

  # Gets the total number of steps beneath this group.
  # Currently this will recursively traverse the tree and fire a whole bunch of queries,
  # one for each ProjectGroup. Should be some way to eager load but not seeing it.
  # Performance shouldn't be too bad though as there shouldn't be that many groups.
  def descendant_step_count
    children.to_a.sum do |c|
      c.is_a?(ProjectStep) ? 1 : c.descendant_step_count
    end
  end

  # Determine if the group's children are all steps or a mix of steps and groups.
  # Also returns true if no children.
  def descendants_only_steps?
    children.each do |c|
      if c.is_a?(ProjectGroup)
        return false
      end
    end
    return true
  end

  # Gets the maximum depth of any group-type descendant of this node.
  def max_descendant_group_depth
    leaf? ? depth : children.to_a.map(&:max_descendant_group_depth).max
  end

  def validate_no_children
    raise DestroyWithChildrenError.new if children.present?
  end

  private

  def has_summary
    if !root? && summary.blank?
      errors.add(:base, :no_summary)
    end
  end

  def ensure_single_root
    if parent_id.nil?
      roots = self.class.where(project_id: project_id, project_type: project_type, parent_id: nil).count
      raise MultipleRootError.new("This project already has a root group") if roots > 0
    end
  end
end
