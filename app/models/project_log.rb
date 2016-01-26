# == Schema Information
#
# Table name: project_logs
#
#  agent_id              :integer
#  created_at            :datetime         not null
#  date                  :date
#  id                    :integer          not null, primary key
#  progress_metric_value :string
#  project_step_id       :integer
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_project_logs_on_agent_id         (agent_id)
#  index_project_logs_on_project_step_id  (project_step_id)
#
# Foreign Keys
#
#  fk_rails_54dbbbb1d4  (agent_id => people.id)
#  fk_rails_67bf2c0e5e  (project_step_id => project_steps.id)
#

class ProjectLog < ActiveRecord::Base
  include Translatable, MediaAttachable, OptionSettable

  belongs_to :project_step
  belongs_to :agent, class_name: 'Person'


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details, :additional_notes, :private_notes

  attr_option_settable :progress_metric


  validates :project_step_id, presence: true


  def name
    # logger.debug "this: #{self.inspect}"
    "#{project_step.try(:name)} log"
  end

  #todo: confirm if we want the shorter alias accessor for the default translation.
  #if so, then generically implement through module
  def progress_metric
    progress_metric_label
  end



  def project
    project_step.try(:project)
  end


  def progress(continuous=false)
    ##JE todo: figure out how this is used and exactly what it needs to show
    raise "todo: project_log.progress"
    language = (I18n.locale == :es ? 'Spanish' : 'English')
    field_name = (continuous ? 'Continuous' : 'WithEvents')
    self.progress_metric.send(language + 'Display' + field_name).capitalize # e.g. EnglishDisplayWithEvents
  end

  def progress_continuous
    self.progress(true)
  end
end
