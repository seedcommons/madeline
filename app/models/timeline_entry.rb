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

class TimelineEntry < ActiveRecord::Base
  include Translatable, OptionSettable

  has_closure_tree

  attr_translatable :summary

  belongs_to :project, polymorphic: true
  belongs_to :agent, class_name: 'Person'

  # This is necessary to allow joins across polymorphic associations. We will probably
  # have to add another one for BasicProjects when we add those.
  belongs_to :loan, -> { where(timeline_entries: { project_type: 'Loan' }) },
    foreign_key: 'project_id'

  delegate :division, :division=, to: :project, allow_nil: true

  scope :by_date, -> { order(:scheduled_start_date) }

  def step?
    is_a?(ProjectStep)
  end

  def group?
    is_a?(ProjectGroup)
  end
end
