# == Schema Information
#
# Table name: loan_health_checks
#
#  created_at           :datetime         not null
#  has_late_steps       :boolean
#  has_sporadic_updates :boolean
#  id                   :integer          not null, primary key
#  last_log_date        :date
#  missing_contract     :boolean
#  progress_pct         :decimal(, )
#  project_id           :integer
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_loan_health_checks_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_6441c92912  (project_id => projects.id)
#

class LoanHealthCheck < ActiveRecord::Base
  belongs_to :loan, class_name: Project, foreign_key: :project_id

  after_create :recalculate

  delegate :active?, to: :loan, prefix: true

  def recalculate
    update(
      missing_contract: check_missing_contract,
      progress_pct: check_progress_pct,
      last_log_date: check_last_log_date,
      has_late_steps: check_has_late_steps,
      has_sporadic_updates: check_sporadic_loan_updates
    )
  end

  def health_warnings
    warnings = []
    warnings << :active_without_signed_contract if loan_active? && missing_contract?
    warnings << :active_without_recent_logs if loan_active? && last_log_date < 30.days.ago
    warnings << :late_steps if has_late_steps?
    warnings << :incomplete_loan_questions if progress_pct < 80
    warnings << :sporadic_loan_updates if has_sporadic_updates?
    warnings
  end

  def healthy?
    health_warnings.count < 1
  end

  private

  def check_missing_contract
    loan.media.where(kind_value: 'contract').count < 1
  end

  def check_has_late_steps
    loan.timeline_entries.merge(ProjectStep.past_due).count > 0
  end

  def check_sporadic_loan_updates
    return false unless loan.end_date
    loan.timeline_entries.merge(ProjectStep.recent).count < [days_old, 30].min
  end

  def check_progress_pct
    return 0 unless loan.criteria
    loan.criteria.progress_pct
  end

  def check_last_log_date
    # To avoid nil checks: If no date found, use the beginning of time.
    loan.project_logs.maximum(:date) || Time.at(0)
  end

  def days_old
    return nil unless loan
    (loan.end_date.beginning_of_day - loan.signing_date.beginning_of_day) / (24 * 60 * 60)
  end
end
