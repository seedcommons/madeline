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

  default_scope { order('scheduled_date') }

  belongs_to :project, polymorphic: true
  belongs_to :agent, class_name: 'Person'

  has_many :project_logs

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :summary, :details

  attr_option_settable :step_type

  validates :project_id, presence: true

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
    if days_late < 0
      I18n.t("project_step.status.days_early", days: -days_late)
    elsif days_late > 0
      I18n.t("project_step.status.days_late", days: days_late)
    else
      I18n.t("project_step.status.on_time")
    end
  end

  # Generate a CSS color based on the status and lateness of the step
  def color
    if completed? && days_late <= 0
      fraction = -days_late / SUPER_EARLY_PERIOD
      color_between(COLORS[:on_time], COLORS[:super_early], fraction)
    elsif days_late > 0
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
 
  def scheduled_day
    self.scheduled_date.day
  end

  def weekday_of_scheduled_date
    Date::DAYNAMES[self.scheduled_date.wday]
  end

  def scheduled_date_weekday_key
    self.week_of_scheduled_date.to_s + "_" + self.weekday_of_scheduled_date.downcase
  end

  # Returns which week within a given month the scheduled date occurs.
  def week_of_scheduled_date
    day = scheduled_day.to_i

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

  # The below methods may need to be moved to the events model
    def calendar_scheduled_event
      cal_item = {}

      cal_item[:start] = self.completed_date ? self.completed_date : self.scheduled_date

      cal_item[:title] = "Step: " + self.name
      cal_item[:event_type] = "project_step"
      cal_item[:backgroundColor] = self.background_color
      cal_item[:borderColor] = self.border_color

      return cal_item
    end

    # TODO: Create way to track changes to scheduled date, including original date
    # and number of times date has changed.

    # TODO: Display ghost steps based on original scheduled date
    # def calendar_original_scheduled_event
    #   if (self.original_scheduled_date != self.scheduled_date)
    #     cal_item = {}

    #     cal_item[:start] = self.original_scheduled_date
    #     cal_item[:title] = self.name
    #     cal_item[:event_type] = "ghost_step"

    #     return cal_item
    #   end
    # end
  # End of methods that may need to be moved to the events model

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
