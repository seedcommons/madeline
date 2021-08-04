class ProjectLog < ApplicationRecord
  include Translatable, MediaAttachable, OptionSettable

  belongs_to :project_step
  belongs_to :agent, class_name: 'Person'

  delegate :division, :division=, :project, to: :project_step
  delegate :name, to: :agent, prefix: true, allow_nil: true

  translates :summary, :details, :additional_notes, :private_notes

  attr_option_settable :progress_metric

  validates :project_step, :date, presence: true
  # TODO: Go back to normal presence validator once translation widget is fixed
  validates :summary, any_translation_presence: true

  after_commit :recalculate_loan_health

  amoeba do
    enable

    include_association :translations
  end

  def name
    I18n.t('project_log.name', date: I18n.l(date), id: id, project: project.name)
  end

  def self.filter_by(params)
    if params[:step].present?
      where(project_step_id: params[:step])
    elsif params[:project].present?
      joins(:project_step).where(timeline_entries: {project_id: params[:project]})
    elsif params[:org].present?
      joins(project_step: :project).where(projects: {organization_id: params[:org]})
    else
      all
    end
  end

  def self.in_division(division)
    if division
      joins(project_step: :project).where(projects: {division_id: division.self_and_descendants.pluck(:id)})
    else
      all
    end
  end

  def self.by_date
    order(Arel.sql("date IS NULL, date DESC, created_at DESC"))
  end

  def recalculate_loan_health
    return unless project_step
    RecalculateLoanHealthJob.perform_later(loan_id: project_step.project_id)
  end

  #todo: confirm if we want the shorter alias accessor for the default translation.
  #if so, then generically implement through module
  def progress_metric
    progress_metric_label
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

  def has_more?
    [details, additional_notes, private_notes, media].any?(&:present?)
  end
end
