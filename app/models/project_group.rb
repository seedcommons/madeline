# == Schema Information
#
# Table name: timeline_entries
#
#  agent_id                   :integer
#  completed_date             :date
#  created_at                 :datetime         not null
#  date_change_count          :integer          default(0), not null
#  finalized_at               :datetime
#  id                         :integer          not null, primary key
#  is_finalized               :boolean
#  original_date              :date
#  parent_id                  :integer
#  project_id                 :integer
#  project_type               :string
#  schedule_ancestor_id       :integer
#  scheduled_duration_seconds :integer          default(0)
#  scheduled_start_date       :date
#  step_type_value            :string
#  type                       :string           not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id                     (agent_id)
#  index_timeline_entries_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_4007acd641  (schedule_ancestor_id => timeline_entries.id)
#  fk_rails_a9dc5eceeb  (agent_id => people.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
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
