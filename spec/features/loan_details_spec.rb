require "rails_helper"

feature "loan details" do
  let!(:div_us) { create(:division, name: "United States", short_name: "us") }
  let!(:loan) do
    create(
      :loan,
      :public, :active, :with_translations, :with_loan_media, :with_coop_media, :with_log_media,
      division: div_us
    )
  end
  let!(:organization) { loan.organization }
  let!(:active_loans) do
    create_list(:loan, 2,
      :public, :active, :with_translations, organization: organization, division: div_us)
  end
  let!(:completed_loans) do
    create_list(:loan, 2,
      :public, :completed, :with_translations, organization: organization, division: div_us)
  end
  let!(:hidden_past_loans) do
    create_list(:loan, 2,
      :public, :prospective, :with_translations, organization: organization, division: div_us)
  end

  before { visit public_loan_path("us", loan) }

  it "should have general information about loan" do
    expect(page).to have_content loan.status
    expect(page).to have_content loan.location
    expect(page).to have_content loan.signing_date_long
    expect(page).to have_content loan.summary
    expect(page).to have_content loan.details
  end

  context "with past loans from same cooperative" do
    it "should show past loan information" do
      active_loans.each do |loan|
        expect(page).to have_content loan.status
        expect(page).to have_content loan.signing_date_long
        expect(page).to have_content loan.summary
      end

      completed_loans.each do |loan|
        expect(page).to have_content loan.status
        expect(page).to have_content loan.signing_date_long
        expect(page).to have_content loan.summary
      end

      hidden_past_loans.each do |loan|
        expect(page).not_to have_content loan.status
        expect(page).not_to have_content loan.signing_date_long
        expect(page).not_to have_content loan.summary
      end
    end
  end

  context "with media" do
    it "should have gallery" do
      gallery_path = public_gallery_path("us", loan)
      gallery_link = page.find("a[href='#{gallery_path}']")
      gallery_link.click
      expect(page).to have_selector(".thumbnail", count: loan.coop_media.size + loan.loan_media.size)
    end
  end

  context "with project events" do
    let!(:loan) { create(:loan, :public, :active, :with_timeline, division: div_us) }
    xit "should have timeline" do
      click_link I18n.t :timeline
      project_events = loan.project_events
      project_events.each do |event|
        expect(page).to have_content event.summary
      end
    end
  end

  context "with repayments" do
    let!(:loan) { create(:loan, :public, :active, :with_repayments, division: div_us) }

    xit "should have repayments" do
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
