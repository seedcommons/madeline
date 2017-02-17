require 'rails_helper'

feature 'loan flow' do
  let(:division) { create(:division) }
  let(:user) { create_member(division) }
  let!(:loan) { create(:loan, division: division) }

  before do
    login_as(user, scope: :user)
  end

  # This should work, but for some reason it fails a lot more often
  include_examples :flow do
    subject { loan }
  end

  describe "timeline" do
    let(:loan) { create(:loan, :with_timeline, division: division) }

    before do
      # TODO: Shouldn't have to do this here. Refactor.
      step_type = OptionSet.create(division: Division.root, model_type: ProjectStep.name,
        model_attribute: 'step_type')
      step_type.options.create(value: 'checkin', label_translations: {en: 'Check-in', es: 'Paso'})
      step_type.options.create(value: 'milestone', label_translations: {en: 'Milestone', es: 'Hito'})
    end

    scenario "works", js: true do
      visit admin_loan_path(loan)
      click_on("Timeline - Table")
      loan.timeline_entries.each do |te|
        expect(page).to have_content(te.summary) if te.is_a?(ProjectStep)
      end

      select("Finalized", from: "status")
      loan.timeline_entries.each do |te|
        next unless te.is_a?(ProjectStep)
        if te.is_finalized?
          expect(page).to have_content(te.summary)
        else
          expect(page).not_to have_content(te.summary)
        end
      end

      select("All Statuses", from: "status")
      select("Milestone", from: "type")
      loan.timeline_entries.each do |te|
        next unless te.is_a?(ProjectStep)
        if te.milestone?
          expect(page).to have_content(te.summary)
        else
          expect(page).not_to have_content(te.summary)
        end
      end
    end
  end

  # Keeping this code here for now. It tended to be more stable than the shared example.
  # Can be deleted when we are happy the shared spec is working.
  # scenario 'can view index', js: true do
  #   visit(admin_loans_path)
  #   expect(page).to have_content(loan.name)
  #
  #   within('#loans') do
  #     click_link(loan.id)
  #   end
  #
  #   expect(page).to have_content("##{loan.id}: #{loan.name}")
  #
  #   visit(admin_loan_path(id: loan.id))
  #   expect(page).to have_content("##{loan.id}: #{loan.name}", wait: 10)
  #   expect(page).to have_content('Edit Loan')
  #
  #   find('.edit-action').click
  #
  #   expect(page).to have_css('#loan_name', visible: true, wait: 10)
  #   fill_in('loan[name]', with: 'Changed Loan Name')
  #
  #   click_button 'Update Loan', wait: 10
  #   expect(page).to have_content("##{loan.id}: Changed Loan Name")
  #   expect(page).to have_content('Record was successfully updated.')
  # end
end
