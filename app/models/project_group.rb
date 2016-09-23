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

  # Prepend required to work with has_closure_tree,
  # otherwise children are deleted before we even get here.
  before_destroy :validate_no_children, prepend: true

  def validate_no_children
    raise DestroyWithChildrenError.new if children.present?
  end
end
