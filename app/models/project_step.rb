# == Schema Information
#
# Table name: timeline_entries
#
#  actual_end_date         :date
#  agent_id                :integer
#  created_at              :datetime         not null
#  date_change_count       :integer          default(0), not null
#  finalized_at            :datetime
#  id                      :integer          not null, primary key
#  is_finalized            :boolean
#  old_duration_days       :integer          default(0)
#  old_start_date          :date
#  parent_id               :integer
#  project_id              :integer
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string           not null
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id    (agent_id)
#  index_timeline_entries_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#  fk_rails_af8b359300  (project_id => projects.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
#  fk_rails_fe366670d0  (schedule_parent_id => timeline_entries.id)
#

require 'chronic'
class ProjectStep < TimelineEntry
  class NoChildrenAllowedError < StandardError; end

  COLORS = {
    on_time: 'hsl(120, 73%, 57%)',
    super_early: 'hsl(120, 41%, 47%)',
    barely_late: 'hsl(56, 100%, 66%)',
    super_late: 'hsl(0, 74%, 54%)',
  }.freeze
  SUPER_EARLY_PERIOD = 7.0 # days
  SUPER_LATE_PERIOD = 30.0 # days
  COMPLETION_STATUSES = %w(draft incomplete complete).freeze

  belongs_to :schedule_parent, class_name: 'ProjectStep', inverse_of: :schedule_children
  has_many :schedule_children, class_name: 'ProjectStep', foreign_key: :schedule_parent_id,
      inverse_of: :schedule_parent, dependent: :nullify

  attr_translatable :details

  attr_option_settable :step_type

  validates :project_id, :step_type_value, presence: true
  validate :unfinalize_allowed
  validate :validate_scheduled_start_date

  before_update :handle_old_start_date_logic
  before_update :handle_old_duration_days_logic
  before_update :handle_schedule_children
  before_update :handle_scheduled_start_date
  before_save :handle_finalized_at
  after_commit :recalculate_loan_health

  # Scheduled end date is calculated
  scope :past_due, -> { where('scheduled_start_date + scheduled_duration_days < ? ', 1.day.ago).where(actual_end_date: nil) }
  scope :recent, -> { where('scheduled_start_date + scheduled_duration_days > ? ', 30.days.ago) }

  def recalculate_loan_health
    RecalculateLoanHealthJob.perform_later(loan_id: project_id)
  end

  def name
    summary
  end

  def summary_or_none
    summary.blank? ? "[#{I18n.t("common.no_name")}]" : summary.to_s
  end

  # For use in views if record not yet saved.
  def id_or_temp_id
    @id_or_temp_id ||= id || "tempid#{rand(1000000)}"
  end

  def logs_count
    project_logs.count
  end

  def latest_logs(limit = 3)
    project_logs.order(date: :desc, updated_at: :desc).limit(limit)
  end

  # Might be better as a filter
  def schedule_parent=(precedent)
    super(precedent)
    copy_schedule_parent_date
  end

  def schedule_parent_id=(precedent_id)
    super(precedent_id)
    copy_schedule_parent_date
  end

  def has_date?
    scheduled_start_date.present?
  end

  def scheduled_end_date
    return if scheduled_start_date.blank?
    return scheduled_start_date if scheduled_duration_days.blank?
    scheduled_start_date + scheduled_duration_days
  end

  def original_end_date
    return unless scheduled_start_date.present?
    return scheduled_start_date unless old_duration_days || scheduled_duration_days

    if old_duration_days && old_duration_days > 0
      duration = old_duration_days
    else
      duration = scheduled_duration_days
    end

    (old_start_date || scheduled_start_date) + (duration || 0)
  end

  # Gets the actual number of days the step too, based on actual end date and scheduled start date
  def actual_duration_days
    if actual_end_date.present? && scheduled_start_date.present?
      (actual_end_date - scheduled_start_date).to_i
    else
      nil
    end
  end

  # Gets best known start date. Can be nil.
  def display_start_date
    scheduled_start_date
  end

  # Gets best known end date. Can be nil.
  def display_end_date
    actual_end_date || scheduled_end_date
  end

  def dependent_step_start_date
    display_end_date.try(:+, 1)
  end

  # Gets best known duration. nil if both start and end dates are nil.
  def display_duration_days
    if display_start_date.nil? && display_end_date.nil?
      nil
    else
      actual_duration_days || scheduled_duration_days
    end
  end

  def set_completed!(date)
    update_attribute(:actual_end_date, date)
  end

  def completed?
    actual_end_date.present?
  end

  def completion_status
    return 'completed' if completed?
    is_finalized? ? 'draft' : 'incomplete'
  end

  def milestone?
    step_type_value == "milestone"
  end

  def checkin?
    step_type_value == "checkin"
  end

  def last_log_status
    project_logs.order(:date).last.try(:progress)
  end

  # Step status used in timeline list
  # Please use ProjectStepHelper project_step_status in other contexts
  def admin_status
    days = days_late
    if days
      if days <= 0
        I18n.t('project_step.status.on_time')
      else
        I18n.t('project_step.status.days_late', days: days)
      end
    else
      I18n.t(:none)
    end
  end

  def status
    if completed?
      I18n.t :log_completed
    else
      last_log_status
    end
  end

  def date_changed?
    old_start_date.present?
  end

  # Validates that a step may not be unfinalized more than 24 hours since it was previously marked
  # as finalized.  Note, should generally be avoided by front-end logic, but guards against edge
  # cases.
  def unfinalize_allowed
    if is_finalized_changed? && !is_finalized && is_finalized_locked?
      errors.add(:is_finalized, I18n.t("project_step.unfinalize_disallowed"))
    end
  end

  def is_finalized_locked?
    finalized_at && Time.now > finalized_at + 1.day
  end

  def days_late
    if scheduled_start_date
      if completed?
        (actual_end_date - original_end_date).to_i
      else
        ([scheduled_start_date, Date.today].max - original_end_date).to_i
      end
    end
  end

  def date_status_statement
    if days_late && days_late < 0
      I18n.t("project_step.status.days_early", days: -days_late)
    elsif days_late && days_late > 0
      I18n.t("project_step.status.days_late", days: days_late)
    else
      I18n.t("project_step.status.on_time")
    end
  end

  def old_start_date_statement
    I18n.t("project_step.status.changed_times", count: date_change_count)
  end

  # Generate a CSS color based on the status and lateness of the step
  def color(opacity = 1)
    # JE: Note, I'm not why it could happen, but I was seeing an 'undefined method `<=' for nil'
    # error here even though it should not have been able to reach that part of the expression
    # when the actual_end_date was not present, so defensively adding the 'days_late' nil checks.
    if completed? && days_late && days_late <= 0
      fraction = -days_late / SUPER_EARLY_PERIOD
      color_between(COLORS[:on_time], COLORS[:super_early], fraction, opacity)
    elsif days_late && days_late > 0
      fraction = days_late / SUPER_LATE_PERIOD
      color_between(COLORS[:barely_late], COLORS[:super_late], fraction, opacity)
    else # incomplete and not late (use default color)
      nil
    end
  end

  def border_color
    color
  end

  def background_color
    color
  end

  def timeline_background_color
    color(0.5)
  end

  def scheduled_bg
    if completed?
      "inherit"
    else
      color
    end
  end

  def scheduled_start_day
    scheduled_start_date.day
  end

  # Returns a duplication helper object which encapsulate handling of the modal rendering and
  # submit handling.
  def duplication
    @duplication ||= Timeline::StepDuplication.new(self)
  end

  # Note, "is_finalized" means a step is no longer a draft, and future changes should remember the
  # original scheduled date.
  def finalize
    if is_finalized?
      false
    else
      update_attribute(:is_finalized, true)
    end
  end

  # Returns number of days that the step's date is about to be shifted.
  # - If step is about to be set as complete, returns difference between actual_end_date and scheduled_end_date
  # - If step is incomplete, returns number of days the scheduled_end_date has been shifted.
  # - If step is incomplete, returns number of days the scheduled_start_date has been shifted.
  # Assumes that record has pending changes assigned, but not yet saved.
  def pending_days_shifted
    return 0 unless is_finalized?

    # If completed date just got set.
    if scheduled_start_date && actual_end_date && actual_end_date_changed? &&
      actual_end_date_was.blank? && actual_end_date > scheduled_start_date
      return (actual_end_date - scheduled_start_date).to_i
    end

    # If incomplete and scheduled date changed.
    if !completed? && scheduled_start_date_changed? && scheduled_start_date_was && scheduled_start_date
      return (scheduled_start_date - scheduled_start_date_was).to_i
    end

    # If complete and completed date changed.
    if completed? && actual_end_date_changed? && actual_end_date_was && actual_end_date
      return (actual_end_date - actual_end_date_was).to_i
    end

    0
  end

  def pending_duration_change?
    is_finalized? && scheduled_duration_days_changed?
  end

  def calendar_events
    CalendarEvent.build_for(self)
  end

  def add_child(_)
    raise NoChildrenAllowedError
  end

  # Needed to satisfy a duck type.
  def max_descendant_group_depth
    parent.depth
  end

  private

  def validate_scheduled_start_date
    if schedule_parent && display_start_date != schedule_parent.dependent_step_start_date
      errors.add(:scheduled_start_date, "start date must match precedent step end date")
    end
  end

  def copy_schedule_parent_date
    if schedule_parent
      self.scheduled_start_date = schedule_parent.dependent_step_start_date
    end
  end

  def handle_old_start_date_logic
    # Note, "is_finalized" means a step is no longer a draft, and future changes should remember
    # the original scheduled date.
    return unless persisted? && scheduled_start_date_changed? && is_finalized?

    if old_start_date.blank?
      self.old_start_date = scheduled_start_date_was
    end
    self.date_change_count = self.date_change_count.to_i.succ
  end

  def handle_old_duration_days_logic
    # Set old duration days once and only if the step is finalized (not a draft)
    return unless persisted? && scheduled_duration_days_changed? && is_finalized?

    # By default, old_duration_days is set to 0.
    # Only remember old duration if a duration has been set other than the default and then changed.
    unless old_duration_days > 0
      self.old_duration_days = scheduled_duration_days_was
    end
  end

  def handle_finalized_at
    if is_finalized && !finalized_at
      self.finalized_at = Time.now
    elsif !is_finalized && finalized_at
      self.finalized_at = nil
    end
  end

  # Copies date changes to schedule_children as appropriate.
  def handle_schedule_children
    return unless persisted? && schedule_children.present? &&
      (scheduled_start_date_changed? || scheduled_duration_days_changed? || actual_end_date_changed?)

    schedule_children.each do |step|
      step.scheduled_start_date = dependent_step_start_date
      step.save!
    end
  end

  # Checks that old_start_date is not present if scheduled_start_date is blank.
  # Sets scheduled_start_date to actual_end_date if actual_end_date
  # is present but scheduled_start_date is blank.
  def handle_scheduled_start_date
    return unless persisted?
    raise ArgumentError if scheduled_start_date.blank? && old_start_date.present?
    return unless actual_end_date && scheduled_start_date.blank?

    self.scheduled_start_date = actual_end_date
  end

  # start and finish are each CSS color strings in hsl format
  def color_between(start, finish, fraction = 0.5, opacity = 1)
    # hsl to array
    start = start.scan(/\d+/).map(&:to_f)
    finish = finish.scan(/\d+/).map(&:to_f)

    fraction = 0 if fraction < 0
    fraction = 1 if fraction > 1

    r = start.each_with_index.map { |val, i| val + (finish[i] - val) * fraction }
    "hsla(#{r[0]}, #{r[1]}%, #{r[2]}%, #{opacity})"
  end
end
