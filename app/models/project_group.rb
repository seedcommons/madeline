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
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id    (agent_id)
#  index_timeline_entries_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#  fk_rails_af8b359300  (project_id => projects.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
#  fk_rails_fe366670d0  (schedule_parent_id => timeline_entries.id)
#

require 'chronic'
class ProjectGroup < TimelineEntry
  class DestroyWithChildrenError < StandardError; end
  class MultipleRootError < StandardError; end

  # Optional set of filters to be applied when fetching children.
  attr_reader :filters

  # Causing migration problems. Is this really necessary? ~Fuzzy
  # validate :has_summary

  before_create :ensure_single_root

  # Prepend required to work with has_closure_tree,
  # otherwise children are deleted before we even get here.
  before_destroy :validate_no_children, prepend: true

  def summary_or_none
    summary.blank? ? "[#{I18n.t("none")}]" : summary.to_s
  end

  def steps
    descendants.where(type: 'ProjectStep')
  end

  def set_dates!
    self.scheduled_start_date = steps.map(&:scheduled_start_date).compact.min
    scheduled_end_date = steps.map(&:scheduled_end_date).compact.max
    if scheduled_start_date && scheduled_end_date
      self.scheduled_duration_days = (scheduled_end_date - scheduled_start_date).to_i
    end
    save! if scheduled_start_date || scheduled_end_date
  end

  # Copies filters down through all descendant groups and resets memoization of filtered_children.
  def filters=(filters)
    @filters = filters
    @filtered_children = nil # Undo memoization
    children.each { |child| child.filters = filters if child.group? }
  end

  def filtered_children
    @filtered_children ||= children.by_date.reject do |child|
      filters.present? && child.step? &&
        (filters[:type] && child.step_type_value != filters[:type] ||
        filters[:status] && child.completion_status != filters[:status])
    end
  end

  # Gets the total number of steps or childless groups beneath this group.
  # Currently this will recursively traverse the tree and fire a whole bunch of queries,
  # one for each ProjectGroup. Could improve performance by using closure_tree's _including_tree.
  # Performance shouldn't be too bad though as there shouldn't be that many groups.
  def descendant_leaf_count
    filtered_children.to_a.sum do |c|
      if c.step? || c.filtered_children.empty?
        1
      else
        c.descendant_leaf_count
      end
    end
  end

  # Determine if the group's children are all steps or a mix of steps and groups.
  # Also returns true if no children.
  def descendants_only_steps?
    filtered_children.each do |c|
      return false if c.group?
    end
    true
  end

  # Gets the maximum depth of any group-type descendant of this node.
  def max_descendant_group_depth
    filtered_children.empty? ? depth : filtered_children.to_a.map(&:max_descendant_group_depth).max
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
      roots = self.class.where(project_id: project_id, parent_id: nil).count
      raise MultipleRootError.new("This project already has a root group") if roots > 0
    end
  end
end
