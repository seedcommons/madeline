require 'rails_helper'

feature 'timeline batch actions', js: true do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:loan) { create(:loan, :with_timeline, division: division) }

  # Create a step with a dependent step, which also has a dependent step
  let(:step1) { create(:project_step, project: loan) }
  let(:step2) { create(:project_step, project: loan, scheduled_start_date: nil, schedule_parent: step1) }
  let(:step3) { create(:project_step, project: loan, scheduled_start_date: nil, schedule_parent: step2) }

  # Create two independent steps, one with and the other without a scheduled start date
  let(:step4) { create(:project_step, project: loan, scheduled_start_date: Date.today, scheduled_duration_days: nil) }
  let(:step5) { create(:project_step, project: loan, scheduled_start_date: nil, scheduled_duration_days: nil) }

  let(:steps) { [step1, step2, step3, step4, step5] }

  before do
    login_as(user, scope: :user)

    # Add the steps to the loan
    loan.root_timeline_entry.children += steps
  end

  it 'changes dates' do
    # Set variables
    step1_orig_date = step1.scheduled_start_date
    step2_orig_date = step2.scheduled_start_date
    step3_orig_date = step3.scheduled_start_date
    step4_orig_date = step4.scheduled_start_date
    step5_orig_date = step5.scheduled_start_date

    days_shifted = 3

    # Select steps
    visit(admin_loan_path(loan) + '/timeline')
    find(:css, ".select-step[data-id='#{step1.id}']").set(true)
    find(:css, ".select-step[data-id='#{step2.id}']").set(true)
    find(:css, ".select-step[data-id='#{step3.id}']").set(true)
    find(:css, ".select-step[data-id='#{step4.id}']").set(true)
    find(:css, ".select-step[data-id='#{step5.id}']").set(true)

    # Adjust dates batch action
    click_on('Batch Actions')
    find(:css, ".batch-actions .action.adjust-dates").click
    fill_in('num_of_days', with: days_shifted)
    find(:css, ".action.adjust-dates-confirm").click
    expect(page).to have_content('successfully updated')

    # Confirm dependent steps change correctly
    expect(step1.reload.scheduled_start_date).to eq(step1_orig_date.try(:+, days_shifted))
    expect(step2.reload.scheduled_start_date).to eq(step2_orig_date.try(:+, days_shifted))
    expect(step3.reload.scheduled_start_date).to eq(step3_orig_date.try(:+, days_shifted))

    # Confirm steps with and without start dates change correctly
    expect(step4.reload.scheduled_start_date).to eq(step4_orig_date.try(:+, days_shifted))
    expect(step5.reload.scheduled_start_date).to eq(step5_orig_date.try(:+, days_shifted))
  end
end
