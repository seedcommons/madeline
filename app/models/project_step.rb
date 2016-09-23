# == Schema Information
#
# Table name: timeline_entries
#
#  agent_id                :integer
#  completed_date          :date
#  created_at              :datetime         not null
#  date_change_count       :integer          default(0), not null
#  finalized_at            :datetime
#  id                      :integer          not null, primary key
#  is_finalized            :boolean
#  original_date           :date
#  parent_id               :integer
#  project_id              :integer
#  project_type            :string
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id                     (agent_id)
#  index_timeline_entries_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
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

  belongs_to :schedule_parent, class_name: 'ProjectStep'
  has_many :schedule_children, class_name: 'ProjectStep', foreign_key: :schedule_parent_id

  has_many :project_logs, dependent: :destroy

  attr_translatable :details

  attr_option_settable :step_type

  validates :project_id, presence: true
  validate :unfinalize_allowed

  before_save :handle_original_date_logic
  before_save :handle_finalized_at
  before_save :handle_schedule_children

  def name
    summary
  end

  # For use in views if record not yet saved.
  def id_or_temp_id
    @id_or_temp_id ||= id || "tempid#{rand(1000000)}"
  end

  def logs_count
    project_logs.count
  end

  # Might be better as a filter
  def schedule_parent=(parent)
    schedule_parent_has_changed(parent) if parent
    super(parent)
  end

  # Since this is called from a before_save callback, we need the unsaved parent
  # as child.schedule_parent will return the old date and fail in the schedule_start_date setter
  def schedule_parent_has_changed(parent)
    self[:scheduled_start_date] = parent.scheduled_end_date
  end

  def scheduled_start_date=(date)
    raise ArgumentError if date.blank?
    raise ArgumentError if schedule_parent && schedule_parent.scheduled_end_date != date
    super(date)
  end

  def scheduled_end_date
    scheduled_start_date + scheduled_duration_days
  end

  def set_completed!(date)
    update_attribute(:completed_date, date)
  end

  def completed?
    completed_date.present?
  end

  def completed_or_not
    completed? ? 'completed' : 'incomplete'
  end

  def milestone?
    self.step_type_value == "milestone" ? true : false
  end

  def last_log_status
    project_logs.order(:date).last.try(:progress)
  end

  def admin_date_status
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

  def admin_status
    last_log_status || admin_date_status
  end

  def status
    if completed?
      I18n.t :log_completed
    else
      last_log_status
    end
  end

  def display_date
    I18n.l completed_date || scheduled_start_date, format: :long
  end

  def date_changed?
    original_date.present?
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

  # The date to use when calculating days_late.
  def on_time_date
    original_date || scheduled_start_date
  end

  def days_late
    if scheduled_start_date
      if completed?
        (completed_date - on_time_date).to_i
      else
        ([scheduled_start_date, Date.today].max - on_time_date).to_i
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

  def original_date_statement
    I18n.t("project_step.status.changed_times", count: date_change_count)
  end

  # Generate a CSS color based on the status and lateness of the step
  def color
    # JE: Note, I'm not why it could happen, but I was seeing an 'undefined method `<=' for nil'
    # error here even though it should not have been able to reach that part of the expression
    # when the completed_date was not present, so defensively adding the 'days_late' nil checks.
    if completed? && days_late && days_late <= 0
      fraction = -days_late / SUPER_EARLY_PERIOD
      color_between(COLORS[:on_time], COLORS[:super_early], fraction)
    elsif days_late && days_late > 0
      fraction = days_late / SUPER_LATE_PERIOD
      color_between(COLORS[:barely_late], COLORS[:super_late], fraction)
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
      update!(is_finalized: true)
    end
  end

  # Returns number of days that the step's calendar date is about to be shifted.
  # - If step is incomplete, returns number of days the scheduled start date has been shifted.
  # - If step is about to be set as complete, returns number of days late or early (negative).
  # - If step was already complete, returns number of days completed date has been shifted.
  # Assumes that record has pending changes assigned, but not yet saved.
  def pending_days_shifted
    return 0 unless is_finalized?

    # If completed date just got set.
    if scheduled_start_date && completed_date && completed_date_changed? &&
      completed_date_was.blank? && completed_date > scheduled_start_date
      return (completed_date - scheduled_start_date).to_i
    end

    # If incomplete and scheduled date changed.
    if !completed? && scheduled_start_date_changed? && scheduled_start_date_was && scheduled_start_date
      return (scheduled_start_date - scheduled_start_date_was).to_i
    end

    # If complete and completed date changed.
    if completed? && completed_date_changed? && completed_date_was && completed_date
      return (completed_date - completed_date_was).to_i
    end

    0
  end

  def calendar_date
    completed? ? completed_date : scheduled_start_date
  end

  def calendar_events
    CalendarEvent.build_for(self)
  end

  def add_child(_)
    raise NoChildrenAllowedError
  end

  private

  def handle_original_date_logic
    # Note, "is_finalized" means a step is no longer a draft, and future changes should remember
    # the original scheduled date.
    if scheduled_start_date_changed? && is_finalized?
      if original_date.blank?
        self.original_date = scheduled_start_date_was
      end
      self.date_change_count = self.date_change_count.to_i.succ
    end
  end

  def handle_finalized_at
    if is_finalized && !finalized_at
      self.finalized_at = Time.now
    elsif !is_finalized && finalized_at
      self.finalized_at = nil
    end
  end

  def handle_schedule_children
    return unless persisted? && scheduled_start_date_changed? && schedule_children.present?

    schedule_children.each do |step|
      step.schedule_parent_has_changed(self)
      step.save
    end
  end

  # start and finish are each CSS color strings in hsl format
  def color_between(start, finish, fraction = 0.5)
    # hsl to array
    start = start.scan(/\d+/).map(&:to_f)
    finish = finish.scan(/\d+/).map(&:to_f)

    fraction = 0 if fraction < 0
    fraction = 1 if fraction > 1

    r = start.each_with_index.map { |val, i| val + (finish[i] - val) * fraction }
    "hsl(#{r[0]}, #{r[1]}%, #{r[2]}%)"
  end
end
