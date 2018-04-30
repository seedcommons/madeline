require 'rails_helper'

feature 'visit loan index page' do
  before do
    @loan_1 = create :loan, :active, :featured, name: 'First loan'
    @loan_2 = create :loan, :active, :featured, name: 'Second loan'
    @loan_3 = create :loan, :active, :featured, name: 'Third loan'
    @loans =  [@loan_1, @loan_2, @loan_3]
    d1 = create(:division, name: 'chicken', short_name: 'chick', loans: [@loan_1])
    create(:division, name: 'pokemon', short_name: 'pikachu', loans: [@loan_2])
    create(:division, name: 'from d1', short_name: 'fire', loans: [@loan_3], parent: d1)
    create(:division, name: 'kale', short_name: 'kk', public: false)
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

    context 'filters with divisions' do
      scenario 'shows loans of division and descendant divisions' do
        # when division with descendants is selected
        visit public_loans_path(division: 'chick')
        save_and_open_page
        expect(page).not_to have_content(@loan_2.name)
        expect(page).to have_content(@loan_1.name)
        expect(page).to have_content(@loan_3.name)

        # when division without descendant is selected
        visit public_loans_path(division: 'pikachu')
        expect(page).not_to have_content(@loan_1.name)
        expect(page).not_to have_content(@loan_3.name)
        expect(page).to have_content(@loan_2.name)

        visit public_loans_path(division: 'fire')
        expect(page).not_to have_content(@loan_1.name)
        expect(page).not_to have_content(@loan_2.name)
        expect(page).to have_content(@loan_3.name)

        # when no division is filtered
        visit public_loans_path
        expect(page).to have_content(@loan_1.name)
        expect(page).to have_content(@loan_2.name)
        expect(page).to have_content(@loan_3.name)
      end
    end

    context 'show only public divisions on dropdown' do
      scenario 'non-public divisions do not show' do
        expect(page.all('select#division option').map(&:value)).to eq %w(all chick pikachu)
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
