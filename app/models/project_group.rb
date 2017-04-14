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
  before_update :check_parent_changes

  # Prepend required to work with has_closure_tree,
  # otherwise children are deleted before we even get here.
  before_destroy :validate_no_children, prepend: true

  def empty?
    children.none?
  end

  def filtered_empty?
    filtered_children.none?
  end

  def summary_or_none
    summary.blank? ? "[#{I18n.t("none")}]" : summary.to_s
  end

  def scheduled_start_date
    return @scheduled_start_date if defined?(@scheduled_start_date)
    @scheduled_start_date = children.map(&:scheduled_start_date).compact.min
  end

  def scheduled_end_date
    return @scheduled_end_date if defined?(@scheduled_end_date)
    @scheduled_end_date = children.map(&:scheduled_end_date).compact.max
  end

  def scheduled_duration_days
    return @scheduled_duration_days if defined?(@scheduled_duration_days)
    @scheduled_duration_days = if scheduled_end_date && scheduled_start_date
      scheduled_end_date - scheduled_start_date
    else
      nil
    end
  end

  # Copies filters down through all descendant groups and resets memoization of filtered_children.
  def filters=(filters)
    @filters = filters
    @filtered_children = nil # Undo memoization
    children.each { |child| child.filters = filters if child.group? }
  end

  def filtered_children
    @filtered_children ||= children.sort_by(&:sort_key).reject do |child|
      filters.present? && child.step? && (
        filters[:type].present? && child.step_type_value != filters[:type] ||
        filters[:status] == 'finalized' && !child.is_finalized ||
        filters[:status] == 'incomplete' && child.completed? ||
        filters[:status] == 'complete' && !child.completed?
      )
    end
  end

  # Returns a flat array of the descendant groups, pre-ordered.
  # Combine with indented_option_label to show groups in tree structure.
  def self_and_descendant_groups_preordered
    [self, filtered_children.select(&:group?).map(&:self_and_descendant_groups_preordered)].flatten
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

  def check_parent_changes
    if parent_id_changed? && parent_id_was.nil?
      raise ArgumentError.new("Parent of root group cannot be changed")
    elsif parent_id_changed? && parent_id.nil?
      raise ArgumentError.new("Parent of project group cannot be empty")
    end
  end
end
