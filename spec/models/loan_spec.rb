require 'rails_helper'

describe Loan do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'media_attachable'
  it_should_behave_like 'option_settable', ['status', 'loan_type', 'project_type', 'public_level']

  before { seed_data }

  it 'has a valid factory' do
    expect(create(:loan)).to be_valid
  end

  context 'model methods' do
    let(:loan) { create(:loan) }

    describe '.name' do
      context 'with cooperative' do
        it 'uses cooperative name' do
          expect(loan.name).to eq I18n.t :project_with, name: loan.organization.name
        end
      end

      #JE todo: confirm if we still want to allow loans record creation w/o an org.
      context 'without cooperative' do
        let(:loan) { create(:loan, cooperative: nil) }
        it 'uses project id' do
          pending('is not currently possible given DB constraints')
          expect(loan.name).to eq I18n.t :project_id, id: loan.id.to_s
        end
      end
    end

    describe '.country' do
      context 'with country' do
        before do
          @country = create(:country, name: 'Argentina')
          @division = create(:division)
          @organization = create(:organization, country: @country)
          @loan = create(:loan, division: @division, organization: @organization)
        end

        it 'gets country' do
          expect(@loan.country).to eq @country
          expect(@loan.country.name).to eq 'Argentina'
        end
      end

      #JE todo: confirm if this logic is  still relevant
      context 'without country' do
        before do
          @organization = create(:organization)
          @loan = create(:loan, organization: @organization)
          @us = create(:country, iso_code: 'US')
        end

        it 'gets united states' do
          expect(@loan.country).to eq @us
        end
      end
    end

    describe '.location' do
      let(:loan) do
        @country_us = create(:country, name: 'United States')
        create(
          :loan,
          organization: create(:organization, country: @country_us, city: 'Ann Arbor')
        )
      end
      it 'returns city and country' do
        expect(loan.location).to eq 'Ann Arbor, United States'
      end

      context 'without city' do
        before { pending 'confirm if the default country is still relevant and desireable' }
        let(:loan) { create(:loan, organization: create(:organization, country: @country_us, city: "")) }

        it 'returns country' do
          expect(loan.location).to eq loan.country.name
        end
      end

      ## JE todo: confirm if a need to implement and test logic to inherit country from divisions associated org
    end

    describe '.signing_date_long' do
      let(:loan) { create(:loan, signing_date: Date.civil(2011, 11, 11)) }
      it 'returns long formatted date' do
        expect(loan.signing_date_long).to eq 'November 11, 2011'
      end
    end

    describe '.status' do
      before do
        # note, need to use specific dependent data here instead of factories, in order to match the expected I18n text below
        Language.find_or_create_by(name: 'English', code: 'EN')
        option_set = Loan.status_option_set
        option_set.create_option(value: 'active').set_label_list(en: 'Active')
        option_set.create_option(value: 'completed').set_label_list(en: 'Completed')
      end
      context 'with active loan' do
        let(:loan) { create(:loan, :active) }
        it 'returns active' do
          expect(loan.status).to eq I18n.t(:loan_active)
        end
      end

      context 'with completed loan' do
        let(:loan) { create(:loan, :completed) }
        it 'returns complete' do
          expect(loan.status).to eq I18n.t(:loan_completed)
        end
      end
    end

    describe '.project_events' do
      # before { pending 'depends on project code' }
      let!(:loan) { create(:loan) }
      let!(:project_events) do
        project_events = []
        project_events << create_list(:project_step, 2, :past, :completed, :with_logs, project: loan)
        project_events << create_list(:project_step, 8, :past, project: loan)
        project_events << create_list(:project_step, 2, :future, project: loan)
        project_events << create_list(:project_step, 2, :past, :completed, project: loan)
        project_events << create_list(:project_step, 2, :past, :with_logs, project: loan)
        project_events.flatten
      end

      it 'it should return all future events and past events if they are complete or have logs' do
        events = loan.project_events
        expect(events.size).to eq 8
        events.each do |event|
          if event.project_logs.empty? && !event.completed?
            expect(event.scheduled_date).to be > Time.zone.today
          end
        end
      end
    end

    describe '.featured_pictures' do
      let(:loan) { create(:loan, :with_loan_media, :with_coop_media) }

      it 'has a default limit of 1' do
        expect(loan.featured_pictures.size).to eq 1
      end

      it 'respects the limit for larger limits' do
        expect(loan.featured_pictures(limit = 3).size).to eq 3
      end

      describe 'sorting' do
        let!(:loan) { create(:loan, :with_one_project_step) }
        let!(:loan_pics) do
          create_list(:media, 2, :with_sort_order, media_attachable: loan).sort_by(&:sort_order)
        end
        let!(:coop_pics) do
          create_list(:media, 2,  :with_sort_order, media_attachable: loan.organization).sort_by(&:sort_order)
        end
        let!(:log_pics) do
          log_pics = []
          loan.logs.each do |log|
            log_pics << create_list(:media, 2, :with_sort_order, media_attachable: log).sort_by(&:sort_order)
          end
          log_pics.flatten
        end

        it 'sorts using first coop pic, loan pics, log pics, and fills in with coop pics' do
          sorted_pics = [coop_pics.first, loan_pics.first, loan_pics.last, log_pics, coop_pics.last].flatten
          expect(loan.featured_pictures(limit = 10)).to eq sorted_pics
        end
      end

    end

  end
end
