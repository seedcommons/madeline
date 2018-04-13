require 'rails_helper'

feature 'visit loan index page' do
  before do
    @loans = create_list(:loan, 3, :active, :featured)
    create(:division, name: 'chicken')
    create(:division, name: 'kale', public: false)
  end

  context 'on the loan index page' do
    before { visit public_loans_path }

    it 'shows active loans' do
      active_loans = @loans.select{ |loan| loan.status_value == 'active' }
      expect(active_loans).to be_present
      active_loans.each do |loan|
        check_loan_content(loan)
      end
    end

    context 'with both active and completed loans' do
      before { @loans = create_list(:loan, 10, :featured) }

      it 'shows completed loans on their tab' do
        click_link 'Completed'
        completed_loans = @loans.select{ |loan| loan.status_value == 'completed' }
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
      before { @loans = create_list(:loan, 25, :active, :featured) }
      it 'paginates loan list' do
        visit public_loans_path
        expect(page).to have_selector('div.pagination ul.pagination li a[rel="next"]')
        loan_items = page.all('tr.loans_items')
        expect(loan_items.size).to be < 25
      end
    end

    context 'with translations' do
      before { @loans = create_list(:loan, 3, :with_translations, :featured) }
      it 'renders translated loan description' do
        click_link 'All'
        @loans.each do |loan|
          expect(page).to have_content loan.summary
        end
      end
    end

    context 'with no local translations' do
      before { @loans = create_list(:loan, 3, :with_foreign_translations, :featured) }
      it 'renders loan description with translation hint' do
        click_link 'All'
        @loans.each do |loan|
          expect(page).to have_content loan.summary
        end
        expect(page).to have_selector '.loans_items span.translation.foreign_language', count: 3
      end
    end

    context 'with divisions' do
      scenario 'filters with division' do
        select 'chicken', from: 'division'
        @loans.each do |loan|
          expect(page).to have_content loan.summary
        end
      end
    end

    context 'show only public divisions on dropdown' do
      scenario 'non-public decisions do not show' do
        expect(page.all('select#division option').map(&:value)).to eq ['all divisions', 'chicken']
      end
    end
  end
end

def check_loan_content(loan)
  expect(page).to have_link loan.display_name, href: public_loan_path(loan)
  expect(page).to have_content loan.signing_date_long
  expect(page).to have_content loan.summary
  expect(page).to have_content loan.location
end
