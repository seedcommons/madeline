require 'rails_helper'

feature 'visit loan index page' do
  let!(:div_us) { create(:division, name: "United States", short_name: "us") }
  let!(:div_pkmn) { create(:division, name: "The Pokémon", short_name: "pkmn") }
  let!(:div_pika) { create(:division, name: "The Pikachu", short_name: "pika", parent: div_pkmn) }
  let!(:div_kale) { create(:division, name: "The Kale", short_name: "kale", public: false) }

  let!(:loan_us) { create(:loan, :active, :featured, name: 'US loan', division: div_us) }
  let!(:loan_pkmn) { create(:loan, :active, :featured, name: 'Pokémon loan', division: div_pkmn) }
  let!(:loan_pika) { create(:loan, :active, :featured, name: 'Pikachu Loan', division: div_pika) }
  let!(:loan_kale) { create(:loan, :active, :featured, name: 'Kale Loan', division: div_kale) }

  let!(:loans) { [loan_us, loan_pkmn, loan_pika, loan_kale] }

  context 'on the loan index page' do
    before { visit public_loans_path("us", division: "all") }

    it 'shows active loans' do
      active_loans = loans.select { |loan| loan.status_value == 'active' }.reject { |loan| loan.name == 'Kale Loan' }
      expect(active_loans).to be_present
      active_loans.each do |loan|
        check_loan_content(loan)
      end
    end

    context 'with both active and completed loans' do
      let!(:loans) do
        [
          create_list(:loan, 3, :active, :featured, division: div_us),
          create_list(:loan, 3, :completed, :featured, division: div_us)
        ].flatten
      end

      it 'shows completed loans on their tab' do
        click_link 'Completed'
        completed_loans = loans.select { |loan| loan.status_value == 'completed' }
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
      let!(:loans) { create_list(:loan, 3, :with_translations, :active, :featured, division: div_us) }

      it 'renders translated loan description' do
        click_link 'All'
        loans.each do |loan|
          expect(page).to have_content loan.summary
        end
      end
    end

    context 'with no local translations' do
      let!(:loans) { create_list(:loan, 3, :with_foreign_translations, :active, :featured, division: div_us) }

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
        scenario 'show all loans by default' do
          visit public_loans_path("us")
          expect(page).to have_content(loan_pkmn.name)
          expect(page).to have_content(loan_us.name)
        end
      end
    end

    context 'show only public divisions on dropdown' do
      scenario 'non-public divisions do not show' do
        expect(page.all('select#division option').map(&:value)).to eq %w(all pkmn pika us)
      end
    end

    scenario 'show loans filtered by divisions' do
      click_on 'The Pokémon'
      within('.no-more-tables') do
        expect(page).not_to have_content('US loan')
      end
      expect(page).to have_content('The Pokémon')
      expect(page).to have_content('The Pikachu')
      expect(page).to have_select('division', selected: 'The Pokémon')
      expect(page.current_url).to have_content('/us/loans?division=pkmn')
    end
  end
end

def check_loan_content(loan)
  expect(page).to have_link loan.display_name, href: public_loan_path("us", loan)
  expect(page).to have_content loan.signing_date_long
  expect(page).to have_content loan.summary
  expect(page).to have_content loan.location
end
