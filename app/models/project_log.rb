class ProjectLog < ActiveRecord::Base
  include TranslationModule, MediaModule

  belongs_to :paso, :foreign_key => 'PasoID', class_name: 'ProjectEvent'
  belongs_to :progress_metric, :foreign_key => 'ProgressMetric'

  def project
    project_table_model = Object.const_get(self.project_table.classify)
    project_table_model.find(self.project_id)
  end

  def explanation
    self.translation('Explanation')
  end
  def detailed_explanation
    self.translation('DetailedExplanation')
  end

  def progress(continuous=false)
    language = (I18n.locale == :es ? 'Spanish' : 'English')
    field_name = (continuous ? 'Continuous' : 'WithEvents')
    self.progress_metric.send(language + 'Display' + field_name).capitalize # e.g. EnglishDisplayWithEvents
  end
  def progress_continuous
    self.progress(true)
  end

  def media(limit=100, images_only=false)
    get_media('ProjectLogs', self.id, limit, images_only)
  end
end
