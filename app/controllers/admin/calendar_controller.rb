class Admin::CalendarController < Admin::AdminController
  def index
    @division = current_division
    @loans = current_division.loans

    authorize @division

    # TODO: Move calendar logic to reusable concern
    @calEvents = []

    @loans.each do |loan|
      if loan[:signing_date] && loan[:target_end_date]
        prepare_event(loan.calendar_start_event)
        prepare_event(loan.calendar_end_event)
      end

      loan.project_steps.each do |step|
        if step.scheduled_date
          prepare_event(step.calendar_scheduled_event)
          
          if step.calendar_original_scheduled_event
            prepare_event(step.calendar_original_scheduled_event)
          end
        end
      end
    end
  end

  # TODO: Move to reusable concern
  def prepare_event(cal_event)
    content = render_to_string(partial: "admin/calendar/event", locals: {cal_event: cal_event}).html_safe
    cal_event[:title] = content
    @calEvents.push(cal_event)
  end
end
