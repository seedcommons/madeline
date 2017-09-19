require 'rails_helper'

feature 'date picker i18n', js: true do
  let(:division) { create(:division) }
  let(:user) { create_admin(division) }
  let!(:loan) { create(:loan, division: division, signing_date: "2017-04-25") }

  before do
    login_as(user, scope: :user)
    page.driver.add_header('Accept-Language', locale)
  end

  context 'english' do
    let(:locale) { 'en' }

    scenario do
      visit admin_loan_path(loan)
      expect(page).to have_css(".loan_signing_date", text: "Apr 25, 2017")
      find("a", text: "Edit Loan").click # Not a normal link so click_link doesn't work
      expect(page).to have_field("Signing Date", with: "2017-04-25")
      pick_aug_19(april_name: "April")
      expect(page).to have_field("Signing Date", with: "2017-08-19")
      click_on("Update Loan")
      expect(page).to have_css(".loan_signing_date", text: "Aug 19, 2017")
    end
  end

  context 'spanish' do
    let(:locale) { 'es' }

    scenario do
      visit admin_loan_path(loan)
      expect(page).to have_css(".loan_signing_date", text: "abr 25, 2017")
      find("a", text: "Editar Préstamo").click
      expect(page).to have_field("Fecha de Firma", with: "2017-04-25")
      pick_aug_19(april_name: "Abril")
      expect(page).to have_field("Fecha de Firma", with: "2017-08-19")
      click_on("Actualizar Préstamo")
      expect(page).to have_css(".loan_signing_date", text: "ago 19, 2017")
    end
  end

  def pick_aug_19(april_name:)
    find("input#loan_signing_date").click
    expect(page).to have_css(".datepicker-days", text: april_name)
    4.times { find(".datepicker-days th.next").click }
    find("td.day", text: "19").click
    find(".content").click
  end
end
