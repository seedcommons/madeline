# == Schema Information
#
# Table name: project_logs
#
#  id                        :integer          not null, primary key
#  agent_id                  :integer
#  created_at                :datetime         not null
#  date                      :date
#  progress_metric_option_id :integer
#  project_step_id           :integer
#  updated_at                :datetime         not null
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
  include Translatable, MediaAttachable

  # create_table :project_logs do |t|
  #   t.references :project_step, index: true
  #   t.references :agent, references: :people, index: true
  #   t.integer :progress_metric_option_id
  #   t.date :date
  #   t.timestamps

  belongs_to :project_step
  belongs_to :agent, class_name: 'Person'


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details, :additional_notes, :private_notes


  validates :project_step_id, presence: true


  def name
    # logger.debug "this: #{self.inspect}"
    "#{project_step.try(:name)} log"
  end


  def progress_metric
    PROGRESS_METRIC_OPTIONS.label_for(progress_metric_option_id)
  end



  PROGRESS_METRIC_OPTIONS = OptionSet.new(
      [ [2,'ahead'],
        [1,'on time'],
        [-1,'behind'],
        [-2,'in need of changing some events'],
        [-3,'in need of changing its whole plan'],
      ])


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
