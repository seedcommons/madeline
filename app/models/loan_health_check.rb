class LoanHealthCheck < ApplicationRecord
  belongs_to :loan, class_name: 'Loan', foreign_key: :loan_id

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
    return false unless loan.projected_end_date

    end_date = loan.projected_end_date.beginning_of_day
    valid_range_count = thirty_day_periods_remaining.times.map do |period|
      end_of_range = end_date - (period * 30).days
      start_of_range = end_date - ((period+1) * 30).days

      [loan.timeline_entries.where('scheduled_start_date < ? and scheduled_start_date > ?', end_of_range, start_of_range).count, 1].min
    end.sum

    valid_range_count != thirty_day_periods_remaining
  end

  def check_progress_pct
    return 0 unless loan.criteria
    loan.criteria.current_user = :system
    loan.criteria.progress_pct
  end

  def check_last_log_date
    # To avoid nil checks: If no date found, use the beginning of time.
    loan.project_logs.maximum(:date) || Time.at(0)
  end

  def thirty_day_periods_remaining
    return nil unless loan
    start_date = ([loan.signing_date || Time.current, Time.current].max).beginning_of_day
    end_date = loan.projected_end_date.beginning_of_day
    ((end_date - start_date) / (24 * 60 * 60)).round / 30
  end
end
