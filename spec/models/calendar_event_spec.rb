require 'rails_helper'

describe CalendarEvent, type: :model do
  describe ".project_step_date_filter" do
    let(:range) { ["2018-02-01", "2018-02-28"] }

    # Steps with actual_end_date
    # start and end inside window
    let!(:step1) { create_step(start_date: "2018-02-04", end_date: "2018-02-07") }
    # start inside window
    let!(:step2) { create_step(start_date: "2018-02-15", end_date: "2018-03-02") }
    # end inside window
    let!(:step3) { create_step(start_date: "2018-01-15", end_date: "2018-02-09") }
    # start before and end after window
    let!(:step4) { create_step(start_date: "2018-01-15", end_date: "2018-03-15") }
    # no overlap
    let!(:step5) { create_step(start_date: "2018-01-15", end_date: "2018-01-31") }
    let!(:step6) { create_step(start_date: "2018-03-15", end_date: "2018-03-19") }

    # Steps without actual_end_date
    # start and end inside window
    let!(:step7) { create_step(start_date: "2018-02-03", duration: 3) }
    # start inside window
    let!(:step8) { create_step(start_date: "2018-02-16", duration: 20) }
    # end inside window
    let!(:step9) { create_step(start_date: "2018-01-15", duration: 20) }
    # start before and end after window
    let!(:step10) { create_step(start_date: "2018-01-14", duration: 60) }
    # no overlap
    let!(:step11) { create_step(start_date: "2018-01-15", duration: 5) }
    let!(:step12) { create_step(start_date: "2018-03-15", duration: 5) }

    # Steps with both scheduled_duration_days and actual_end_date
    # A step with both an end date and a duration should use end date to determine if the step
    # is in the range.
    let!(:step13) { create_step(start_date: "2018-01-15", end_date: "2018-01-20", duration: 30) }

    it "should return the correct steps" do
      expect(CalendarEvent.project_step_date_filter(range, ProjectStep, nil)).
        to contain_exactly(step1, step2, step3, step4, step7, step8, step9, step10)
    end

    def create_step(start_date:, end_date: nil, duration: nil)
      create(:project_step,
        scheduled_start_date: start_date,
        actual_end_date: end_date,
        scheduled_duration_days: duration,
        is_finalized: true
      )
    end
  end
end
