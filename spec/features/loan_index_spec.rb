require 'rails_helper'

feature 'visit loan index page' do
  let!(:loan_us) { create(:loan, :active, :featured, name: 'US loan') }
  let!(:loan_pkmn) { create(:loan, :active, :featured, name: 'Pokémon loan') }
  let!(:loan_pika) { create(:loan, :active, :featured, name: 'Pikachu Loan') }
  let!(:loan_kale) { create(:loan, :active, :featured, name: 'Kale Loan') }

  let!(:div_us) { create(:division, name: "United States", short_name: "us", loans: [loan_us]) }
  let!(:div_pkmn) { create(:division, name: "Pokémon", short_name: "pkmn", loans: [loan_pkmn]) }
  let!(:div_pika) { create(:division, name: "Pikachu", short_name: "pika", loans: [loan_pika], parent: div_pkmn) }
  let!(:div_kale) { create(:division, name: "Kale", short_name: "kale", loans: [loan_kale], public: false) }

  let!(:loans) { [loan_us, loan_pkmn, loan_pika, loan_kale] }

  context 'on the loan index page' do
    before { visit public_loans_path("us", division: "all") }

    it 'shows active loans' do
      active_loans = loans.select{ |loan| loan.status_value == 'active' }.reject{ |loan| loan.name == 'Kale Loan' }
      expect(active_loans).to be_present
      active_loans.each do |loan|
        check_loan_content(loan)
      end
    end

    context 'with both active and completed loans' do
      let!(:loans) { create_list(:loan, 10, :featured, division: div_us) }

      it 'shows completed loans on their tab' do
        click_link 'Completed'
        completed_loans = loans.select{ |loan| loan.status_value == 'completed' }
        completed_loans.each do |loan|
          check_loan_content(loan)
        end
      end

      it 'shows all loans on all tab' do
        click_link 'All'
        loans.each do |loan|
          check_loan_content(loan)
        end
      end
    end

    context 'with many loans' do
      let!(:loans) { create_list(:loan, 25, :active, :featured, division: div_us) }
      it 'paginates loan list' do
        visit public_loans_path("us", division: 'all')
        expect(page).to have_selector('div.pagination ul.pagination li a[rel="next"]')
        loan_items = page.all('tr.loans_items')
        expect(loan_items.size).to be < 25
      end
    end

    context 'with translations' do
      let!(:loans) { create_list(:loan, 3, :with_translations, :featured, division: div_us) }

      it 'renders translated loan description' do
        click_link 'All'
        loans.each do |loan|
          expect(page).to have_content loan.summary
        end
      end
    end

    context 'with no local translations' do
      let!(:loans) { create_list(:loan, 3, :with_foreign_translations, :featured, division: div_us) }

      it 'renders loan description with translation hint' do
        click_link 'All'
        loans.each do |loan|
          expect(page).to have_content loan.summary
        end
        expect(page).to have_selector '.loans_items span.translation.foreign_language', count: 3
      end
    end

    context 'with divisions' do
      context 'with us division' do
        scenario 'filters loans from other divisions' do
          visit public_loans_path("us", division: 'us')
          expect(page).not_to have_content(loan_pkmn.name)
          expect(page).not_to have_content(loan_kale.name)
          expect(page).to have_content(loan_us.name)
        end
      end

      context 'with pkmn division' do
        scenario 'includes only descendants' do
          # when another division is filtered
          visit public_loans_path("us", division: 'pkmn')
          expect(page).not_to have_content(loan_us.name)
          expect(page).not_to have_content(loan_kale.name)
          expect(page).to have_content(loan_pkmn.name)
          expect(page).to have_content(loan_pika.name)
        end
      end

      context 'with all divisions' do
        scenario 'only include public divisions' do
          visit public_loans_path("us", division: 'all')
          expect(page).to have_content(loan_pkmn.name)
          expect(page).to have_content(loan_us.name)
          expect(page).to have_content(loan_pika.name)
          expect(page).not_to have_content(loan_kale.name)
        end
      end

      context 'with no selection' do
        scenario 'use site division by default' do
          visit public_loans_path("us")
          expect(page).not_to have_content(loan_pkmn.name)
          expect(page).to have_content(loan_us.name)
        end
      end
    end

    context 'show only public divisions on dropdown' do
      scenario 'non-public divisions do not show' do
        expect(page.all('select#division option').map(&:value)).to eq %w(all pkmn pika us)
      end
    end
  end
end

def check_loan_content(loan)
  expect(page).to have_link loan.display_name, href: public_loan_path("us", loan)
  expect(page).to have_content loan.signing_date_long
  expect(page).to have_content loan.summary
  expect(page).to have_content loan.location
end
