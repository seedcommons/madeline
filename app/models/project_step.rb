# == Schema Information
#
# Table name: project_steps
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  project_type    :string
#  agent_id        :integer
#  scheduled_date  :date
#  completed_date  :date
#  is_finalized    :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  step_type_value :string
#
# Indexes
#
#  index_project_steps_on_agent_id                     (agent_id)
#  index_project_steps_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_a9dc5eceeb  (agent_id => people.id)
#

class ProjectStep < ActiveRecord::Base
  include ::Translatable, OptionSettable

  belongs_to :project, polymorphic: true
  belongs_to :agent, class_name: 'Person'


  has_many :project_logs


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details

  attr_option_settable :step_type


  validates :project_id, presence: true


  def name
    # logger.debug "this: #{self.inspect}"
    "#{project.try(:name)} step"
  end

  def logs_count
    project_logs.count
  end



  def is_completed
    completed_date.present?
  end

  def completed_or_not
    is_completed ? 'completed' : 'not_completed'
  end

  def completed?
    self.completed_date?
  end

  def status
    if is_completed
      I18n.t :log_completed
    else
      project_logs.order(:date).last.try(:progress)
    end
  end

  def display_date
    I18n.l (self.completed_date || self.scheduled_date), format: :long
  end
end
