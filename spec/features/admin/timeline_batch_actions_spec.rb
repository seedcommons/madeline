require 'rails_helper'

feature 'timeline batch actions' do
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
    # byebug
    visit(admin_loan_path(loan) + '/timeline')
    # save_and_open_page
    find(:css, ".select-step[data-id='#{step1.id}']").set(true)
    find(:css, ".select-step[data-id='#{step2.id}']").set(true)
    find(:css, ".select-step[data-id='#{step3.id}']").set(true)
    click_on('Batch Actions')
    click_on('Adjust Dates')
    fill_in('num_of_days', with: '3')
    click_button('Adjust Dates')
    expect(page).to have_content('successfully updated')
  end
end
