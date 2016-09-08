# == Schema Information
#
# Table name: project_logs
#
#  agent_id              :integer
#  created_at            :datetime         not null
#  date                  :date
#  date_changed_to       :date
#  id                    :integer          not null, primary key
#  progress_metric_value :string
#  timeline_entry_id     :integer
#  timeline_entry_type   :string
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_project_logs_on_agent_id           (agent_id)
#  index_project_logs_on_timeline_entry_id  (timeline_entry_id)
#
# Foreign Keys
#
#  fk_rails_54dbbbb1d4  (agent_id => people.id)
#  fk_rails_7964cb2e36  (timeline_entry_id => timeline_entries.id)
#

class ProjectLog < ActiveRecord::Base
  include Translatable, MediaAttachable, OptionSettable

  belongs_to :project_step, polymorphic: true, foreign_key: :timeline_entry_id, foreign_type: :timeline_entry_type
  belongs_to :agent, class_name: 'Person'

  delegate :division, :division=, to: :project_step
  delegate :name, to: :agent, prefix: true, allow_nil: true

  attr_translatable :summary, :details, :additional_notes, :private_notes

  attr_option_settable :progress_metric

  validates :timeline_entry_id, presence: true

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
    # ##JE todo: figure out how this is used and exactly what it needs to show
    # raise "todo: project_log.progress"
    # language = (I18n.locale == :es ? 'Spanish' : 'English')
    # field_name = (continuous ? 'Continuous' : 'WithEvents')
    # self.progress_metric.send(language + 'Display' + field_name).capitalize # e.g. EnglishDisplayWithEvents

    # todo, confirm needs around 'continuous' display variation
    progress_metric_label
  end

  def progress_continuous
    self.progress(true)
  end
end
