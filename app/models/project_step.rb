# == Schema Information
#
# Table name: project_steps
#
#  agent_id        :integer
#  completed_date  :date
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  is_finalized    :boolean
#  original_date   :date
#  project_id      :integer
#  project_type    :string
#  scheduled_date  :date
#  step_type_value :string
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_project_steps_on_agent_id                     (agent_id)
#  index_project_steps_on_project_type_and_project_id  (project_type,project_id)
#
# Foreign Keys
#
#  fk_rails_a9dc5eceeb  (agent_id => people.id)
#

require 'chronic'

class ProjectStep < ActiveRecord::Base
  include ::Translatable, OptionSettable

  COLORS = {
    on_time: "hsl(120, 73%, 57%)",
    super_early: "hsl(120, 41%, 47%)",
    barely_late: "hsl(56, 100%, 66%)",
    super_late: "hsl(0, 74%, 54%)",
  }
  SUPER_EARLY_PERIOD = 7.0 # days
  SUPER_LATE_PERIOD = 30.0 # days
  # maximum allowed number of records to create when doing a 'duplicate with repeat' operation
  DUPLICATION_RECORD_LIMIT = 60

  default_scope { order('scheduled_date') }

  belongs_to :project, polymorphic: true
  belongs_to :agent, class_name: 'Person'

  delegate :division, :division=, to: :project

  has_many :project_logs, dependent: :destroy

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details

  attr_option_settable :step_type

  validates :project_id, presence: true

  def division
    project.try(:division)
  end

  def update_with_translations(project_step_params, translations_params)
    begin
      # todo: Consider trying to just use nested attributes, but I'm doubtful that we'll be able to handle
      # the form flags to delete translations without something ad hoc
      ActiveRecord::Base.transaction do
        update_translations!(translations_params)
        update!(project_step_params)
        true
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def name
    "#{project.try(:name)} step"
  end

  def logs_count
    project_logs.count
  end

  def completed?
    completed_date.present?
  end

  def completed_or_not
    completed? ? 'completed' : 'not_completed'
  end

  def milestone?
    self.step_type_value == "milestone" ? true : false
  end

  def last_log_status
    project_logs.order(:date).last.try(:progress)
  end

  def admin_status
    last_log_status || I18n.t(:none)
  end

  def status
    if completed?
      I18n.t :log_completed
    else
      last_log_status
    end
  end

  def display_date
    I18n.l (self.completed_date || self.scheduled_date), format: :long
  end

  def original_date
    self[:original_date] || scheduled_date
  end

  def date_changed?
    self[:original_date].present?
  end

  def days_late
    if scheduled_date
      if completed?
        (completed_date - original_date).to_i
      else
        ([scheduled_date, Date.today].max - original_date).to_i
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
    else # incomplete and not late
      "inherit"
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

  def duplication_basis_date
    scheduled_date || Date.today
  end

  def duplication_basis_day
    duplication_basis_date.day
  end

  def duplication_basis_weekday
    Date::DAYNAMES[duplication_basis_date.wday]
  end

  def duplication_basis_weekday_key
    duplication_basis_week.to_s + "_" + duplication_basis_weekday.downcase
  end

  # Returns which week within a given month the scheduled date (or current date if absent) occurs.
  def duplication_basis_week
    day = duplication_basis_day.to_i

    if (day < 8)
      1
    elsif (8 <= day) && (day < 15)
      2
    elsif (15 <= day) && (day < 22)
      3
    elsif (22 <= day) && (day < 29)
      4
    else
      5
    end
  end

  def duplicate_series(frequency, time_unit, month_repeat_on, num_of_occurrences, end_date)
    puts "freq: #{frequency}, time_unit: #{time_unit}, month_repeat_on: #{month_repeat_on}"
    results = []
    allow_error = true
    last_date = duplication_basis_date
    (num_of_occurrences || DUPLICATION_RECORD_LIMIT).times do
      next_date = apply_time_interval(last_date, frequency, time_unit, month_repeat_on)
      puts "next date: #{next_date}"
      break if end_date && next_date > end_date
      results << create_duplicate(next_date, should_persist: true, allow_error: allow_error)
      last_date = next_date
      allow_error = false  # only throw exception if the first record fails
    end

    results
  end

  def apply_time_interval(date, frequency, time_unit, month_repeat_on)
    puts "apply_time_interval - date: #{date}, freq: #{frequency}, time_unit: #{time_unit}, month_repeat_on: #{month_repeat_on}"

    interval = frequency.send(time_unit)
    if time_unit == :days || time_unit == :weeks
      date + interval
    else
      # Note, Chronic doesn't seem to support 'this month' in this context, so need to subtract
      # a month and use 'next month'.
      reference_date = date.beginning_of_month + interval - 1.month
      Chronic.parse("#{month_repeat_on} of next month", now: reference_date)
    end
  end

  def create_duplicate(date = nil, should_persist: true, allow_error: true)
    begin
      date ||= scheduled_date
      new_step = ProjectStep.new(
        project: project,
        agent: agent,
        step_type_value: step_type_value,
        scheduled_date: date,
        original_date: nil,
        completed_date: nil,
        is_finalized: false,
      )
      # This will create transient copies of all of the source translatable attributes.
      clone_translations(new_step)
      new_step.save if should_persist
      new_step
      # Note, would likely want to also copy custom fields at the point in time which we expect
      # those to be used on ProjectSteps.
    rescue => e
      Rails.logger.error("create_duplicate error: #{e}")
      raise e if allow_error
      nil  # Partial failures will be stripped from result list.
    end

  end


  #
  # Translations helpers
  #

  # todo: refactor up to translatable.rb

  def update_translations!(translation_params)
    # deleting the translations that have been removed
    translation_params[:deleted_locales].each do |l|
      [:details, :summary].each do |attr|
        delete_translation(attr, l)
      end
    end

    reload

    # updating/creating the translation that have been updated, added
    permitted_locales.each do |l|
      next if translation_params["locale_#{l}"].nil?
      [:details, :summary].each do |attr|
        # note, old_locale handles the redesignation of a translation set to a different language
        set_translation(attr, translation_params["#{attr}_#{l}"], locale: translation_params["locale_#{l}"], old_locale: l)
      end
    end
    save!
  end

  private

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
