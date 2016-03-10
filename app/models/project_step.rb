# == Schema Information
#
# Table name: project_steps
#
#  agent_id        :integer
#  completed_date  :date
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  is_finalized    :boolean
#  project_id      :integer
#  project_type    :string
#  scheduled_date  :date
#  step_type_value :string
#  updated_at      :datetime         not null
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

  def last_log_status
    project_logs.order(:date).last.try(:progress)
  end

  def admin_status
    last_log_status
  end

  def status
    if is_completed
      I18n.t :log_completed
    else
      last_log_status
    end
  end

  def display_date
    I18n.l (self.completed_date || self.scheduled_date), format: :long
  end

  # Below methods may need to be moved elsewhere
  def completed?
    self.completed_date ? true : false
  end

  def milestone?
    self.step_type_value == "milestone" ? true : false
  end

  def days
    if self.completed?
      self.completed_date - self.scheduled_date
    end
  end

  def border_color
    # Stubbed border color
    if self.completed?
      "rgb(92, 184, 92)"
    else
      "black"
    end
  end

  def background_color
    # Stubbed background color
    color = self.border_color

    if color == "black"
      "inherit"
    else
      color
    end
  end

  def scheduled_bg
    # Stubbed scheduled date background

    if self.completed?
      "inherit"
    else
      self.background_color
    end
  end
end
