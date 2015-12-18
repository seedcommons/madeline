require 'rails_helper'

feature 'visit home page' do
  before { pending 're-implement in new project' }
  before { @loans = create_list(:loan, 3, :active) }
  context 'on the home page' do
    before { visit root_path }

    it 'shows active loans' do
      active_loans = @loans.select{ |loan| loan.status == I18n.t(:loan_active) }
      active_loans.each do |loan|
        check_loan_content(loan)
      end
    end

    context 'with both active and completed loans' do
      before { @loans = create_list(:loan, 10) }

      it 'shows completed loans on their tab' do
        click_link 'Completed'
        completed_loans = @loans.select{ |loan| loan.status == I18n.t(:loan_completed) }
        completed_loans.each do |loan|
          check_loan_content(loan)
        end
      end

      it 'shows all loans on all tab' do
        click_link 'All'
        @loans.each do |loan|
          check_loan_content(loan)
        end
      end
    end

    context 'with many loans' do
      before { @loans = create_list(:loan, 25, :active) }
      it 'paginates loan list' do
        visit root_path
        expect(page).to have_selector('div.pagination ul.pagination li.next a')
        loan_items = page.all('tr.loans_items')
        expect(loan_items.size).to be < 25
      end
    end

    context 'with translations' do
      before { @loans = create_list(:loan, 3, :with_translations) }
      it 'renders translated loan description' do
        visit root_path
        click_link 'All'
        @loans.each do |loan|
          expect(page).to have_content loan.short_description.content
        end
      end
    end

    context 'with no local translations' do
      before { @loans = create_list(:loan, 3, :with_foreign_translations) }
      it 'renders loan description with translation hint' do
        visit root_path
        click_link 'All'
        @loans.each do |loan|
          expect(page).to have_content loan.short_description.content
        end
        expect(page).to have_selector '.loans_items span.translation.foreign_language', count: 3
      end
    end
  end
end

def check_loan_content(loan)
  expect(page).to have_link loan.name, loan_path(loan)
  expect(page).to have_content loan.signing_date_long
  expect(page).to have_content loan.short_description
  expect(page).to have_content loan.location
  expect(page.body).to include loan.amount_formatted
end
