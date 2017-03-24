require 'rails_helper'

feature 'loan details' do
  before { pending 're-implement in new project' }
  let(:loan) { create(:loan) }
  before { visit loan_path(loan) }

  it 'should have general information about loan' do
    expect(page).to have_content loan.status
    expect(page).to have_content loan.location
    expect(page).to have_content loan.signing_date_long
    expect(page).to have_content loan.short_description
    expect(page).to have_content loan.description
  end

  context 'with past loans from same cooperative' do
    before do
      cooperative = loan.organization
      @past_loans = create_list(:loan, 3, cooperative: cooperative)
      visit loan_path(loan)
    end

    it 'should show past loan information' do
      click_link 'Past Loans'
      @past_loans.each do |loan|
        expect(page).to have_content loan.status
        expect(page).to have_content loan.signing_date_long
        expect(page).to have_content loan.short_description
      end
    end
  end

  context 'with media' do
    let(:loan) { create(:loan, :with_coop_media, :with_loan_media) }
    it 'should have gallery' do
      gallery_link = page.find("a[href='#{gallery_path(loan)}']")
      gallery_link.click
      expect(page).to have_selector('.thumbnail', count: loan.coop_media.size + loan.loan_media.size)
    end
  end

  context 'with project events' do
    let(:loan) { create(:loan, :with_project_events) }
    it 'should have timeline' do
      pending 're-enable timeline'
      click_link I18n.t :timeline
      project_events = loan.project_events
      project_events.each do |event|
        expect(page).to have_content event.summary
      end
    end
  end

  context 'with repayments' do
    let(:loan) { create(:loan, :with_repayments) }
    it 'should have repayments' do
      pending 're-enable repayments'
      visit loan_path(loan)
      click_link I18n.t :payments
      repayments = loan.reload.repayments
      repayments.each do |repayment|
        expect(page).to have_content I18n.t repayment.status
        if repayment.status == :paid
          expect(page).to have_content I18n.l repayment.date_paid, format: :long
        else
          expect(page).to have_content I18n.l repayment.date_due, format: :long
        end
      end
    end
  end
end
