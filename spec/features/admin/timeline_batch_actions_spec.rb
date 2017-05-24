require 'rails_helper'

feature 'timeline batch actions', js: true do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:loan) { create(:loan, :with_timeline, division: division) }
  let(:step1) { create(:project_step, project: loan) }
  let(:step2) { create(:project_step, project: loan, scheduled_start_date: nil, schedule_parent: step1) }
  let(:step3) { create(:project_step, project: loan, scheduled_start_date: nil, scheduled_duration_days: nil) }

  before do
    login_as(user, scope: :user)
  end

  it 'changes dates', focus: true do
    loan.root_timeline_entry.children += [step1, step2, step3]

    step1_orig_date = step1.scheduled_start_date
    step2_orig_date = step2.scheduled_start_date
    step3_orig_date = step3.scheduled_start_date
    num = 3

    puts step1.scheduled_start_date
    puts step2.scheduled_start_date
    puts step1.id
    puts step2.id
    puts step3.id

    visit(admin_loan_path(loan) + '/timeline')
    find(:css, ".select-step[data-id='#{step1.id}']").set(true)
    find(:css, ".select-step[data-id='#{step2.id}']").set(true)
    find(:css, ".select-step[data-id='#{step3.id}']").set(true)
    click_on('Batch Actions')
    find(:css, ".batch-actions .action.adjust-dates").click
    fill_in('num_of_days', with: num)
    find(:css, ".action.adjust-dates-confirm").click
    expect(page).to have_content('successfully updated')

    # byebug
    # save_and_open_page
    expect(step1.reload.scheduled_start_date).to eq(step1_orig_date.try(:+, num))
    expect(step2.reload.scheduled_start_date).to eq(step2_orig_date.try(:+, num))
    expect(step3.reload.scheduled_start_date).to eq(step3_orig_date.try(:+, num))

    # print page.html
  end
end
