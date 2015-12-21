class ProjectEvent < ActiveRecord::Base
  include TranslationModule

  has_many :project_logs, :foreign_key => 'PasoID'
  alias_attribute :logs, :project_logs

  def project
    project_table_model = Object.const_get(self.project_table.classify)
    project_table_model.find(self.project_id)
  end

  def completed_or_not
    self.completed ? 'completed' : 'not_completed'
  end

  def status
    if self.completed
      I18n.t :log_completed
    else
      project_logs.order("Date").last.try(:progress)
    end
  end

  def summary
    self.translation('Summary')
  end
  def details
    self.translation('Details')
  end

  def display_date
    I18n.l (self.completed || self.date), format: :long
  end
end
