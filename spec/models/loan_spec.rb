# == Schema Information
#
# Table name: projects
#
#  amount                      :decimal(, )
#  created_at                  :datetime         not null
#  currency_id                 :integer
#  custom_data                 :json
#  division_id                 :integer
#  end_date                    :date
#  first_interest_payment_date :date
#  first_payment_date          :date
#  id                          :integer          not null, primary key
#  length_months               :integer
#  loan_type_value             :string
#  name                        :string
#  organization_id             :integer
#  primary_agent_id            :integer
#  projected_return            :decimal(, )
#  public_level_value          :string
#  rate                        :decimal(, )
#  representative_id           :integer
#  secondary_agent_id          :integer
#  signing_date                :date
#  status_value                :string
#  type                        :string           not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_projects_on_currency_id      (currency_id)
#  index_projects_on_division_id      (division_id)
#  index_projects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_5a4bc9458a  (division_id => divisions.id)
#  fk_rails_7a8d917bd9  (secondary_agent_id => people.id)
#  fk_rails_ade0930898  (currency_id => currencies.id)
#  fk_rails_dc1094f4ed  (organization_id => organizations.id)
#  fk_rails_ded298065b  (representative_id => people.id)
#  fk_rails_e90f6505d8  (primary_agent_id => people.id)
#

require 'rails_helper'

describe Loan, :type => :model do

  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'media_attachable'
  it_should_behave_like 'option_settable', ['status', 'loan_type', 'public_level']

  it 'has a valid factory' do
    expect(create(:loan)).to be_valid
  end

  context 'model methods' do
    let(:loan) { create(:loan) }

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
          @division = create(:division)
          @loan = create(:loan, division: @division.id)
          @us = create(:country, name: "United States")
        end
        xit 'gets united states' do
          expect(@loan.country).to eq @us
        end
      end
    end

    describe '.location' do
      let(:loan) do
        @country_us = create(:country, name: 'United States')
        create(
          :loan,
          organization: create(:organization, country: @country_us, city: 'Ann Arbor'),
          division: create(:division, parent: root_division, organization: create(:organization, country: @country_us))
        )
      end
      it 'returns city and country' do
        expect(loan.location).to eq "Ann Arbor, United States"
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
      let(:loan) { create(:loan, signing_date: Date.civil(2011, 11, 11))}
      it 'returns long formatted date' do
        expect(loan.signing_date_long).to eq "November 11, 2011"
      end
    end

    describe '.status' do
      before do
        # Note, option_set functionality depends on existance of root_division.
        # So if we're not going to enable autocreation within the 'Division.root' logic, then we need
        # to explicitly guarantee existence of the root division for any unit tests which use option sets
        root_division
        option_set = Loan.status_option_set
        option_set.options.create(value: 'active', label_translations: { en: 'Active' })
        option_set.options.create(value: 'completed', label_translations: { en: 'Completed' })
      end
      context 'with active loan' do
        let(:loan) { create(:loan, :active) }
        it 'returns active' do
          expect(loan.status.to_s).to eq I18n.t(:loan_active)
        end
      end

      context 'with completed loan' do
        let(:loan) { create(:loan, :completed) }
        it 'returns complete' do
          expect(loan.status.to_s).to eq I18n.t(:loan_completed)
        end
      end
    end

    describe '.project_events' do
      let!(:loan) { create(:loan) }
      let!(:project_steps) do
        project_steps = []
        project_steps << create_list(:project_step, 2, :past, :completed, :with_logs, :for_loan, project_id: loan.id)
        project_steps << create_list(:project_step, 8, :past, :for_loan, project_id: loan.id)
        project_steps << create_list(:project_step, 2, :future, :for_loan, project_id: loan.id)
        project_steps << create_list(:project_step, 2, :past, :completed, :for_loan, project_id: loan.id)
        project_steps << create_list(:project_step, 2, :past, :with_logs, :for_loan, project_id: loan.id)
        project_steps.flatten
      end

      xit 'it should return all future events and past events if they are complete or have logs' do
        # puts project_steps.awesome_inspect
        events = loan.project_steps
        expect(events.size).to eq 8
        events.each do |event|
          if event.logs.empty? && !event.completed
            expect(event.date).to be > Date.today
          end
        end
      end
    end

    xdescribe '.featured_pictures' do
      let(:loan) { create(:loan, :with_loan_media, :with_coop_media) }

      it 'has a default limit of 1' do
        expect(loan.featured_pictures.size).to eq 1
      end

      it 'respects the limit for larger limits' do
        expect(loan.featured_pictures(limit = 3).size).to eq 3
      end

      describe 'sorting' do
        let!(:loan) { create(:loan, :with_one_project_step) }
        let!(:loan_pics) { create_list(:media, 2, context_table: 'Loans', context_id: loan.id).sort_by(&:media_path) }
        let!(:coop_pics) { create_list(:media, 2, context_table: 'Cooperatives', context_id: loan.cooperative.id).sort_by(&:media_path) }
        let!(:log_pics) do
          log_pics = []
          loan.logs.each do |log|
            log_pics << create_list(:media, 2, context_table: 'ProjectLogs', context_id: log.id).sort_by(&:media_path)
          end
          log_pics.flatten
        end

        it 'sorts using first coop pic, loan pics, log pics, and fills in with coop pics' do
          sorted_pics = [coop_pics.first, loan_pics.first, loan_pics.last, log_pics, coop_pics.last].flatten
          expect(loan.featured_pictures(limit = 10)).to eq sorted_pics
        end
      end

    end

    describe '.progress_pct' do
      subject{ loan.progress_pct }

      context 'without criteria' do
          it 'returns 0' do
            expect(loan.progress_pct).to be 0
          end
      end

      context 'with criteria' do
        let(:progress) { 57 }
        let(:loan) do
          loan = create(:loan, :prospective)
          loan.tap { allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: progress)) }
        end

        it 'matches criteria progress_pct' do
          is_expected.to be progress
        end
      end
    end

    describe '.healthy' do
      subject{ loan.healthy? }

      context 'with no #health_warnings' do
        before do
          allow(loan).to receive(:health_warnings).and_return([])
        end
        let(:loan) do
          loan = create(:loan, :prospective)
          loan.tap { allow(loan).to receive(:health_warnings).and_return([]) }
        end
        it { is_expected.to be true }
        it 'has no health_warnings' do
          expect(loan.health_warnings.count).to eq 0
        end
      end
      context 'with 1 #health_warnings' do
        let(:loan) do
          l = create(:loan, :prospective)
          l.tap { allow(l).to receive(:health_warnings).and_return([:warning_one]) }
        end
        it { is_expected.to be false }
      end
      context 'with multiple #health_warnings' do
        let(:loan) do
          l = create(:loan, :prospective)
          l.tap { allow(l).to receive(:health_warnings).and_return([:warning_one, :warning_two, :warning_three]) }
        end
        it { is_expected.to be false }
      end
    end


    describe '.health_warnings' do
      subject{ loan.health_warnings }

      context 'with new loan' do
        context 'and no steps at all' do
          let(:loan) { create(:loan, :prospective) }

          context 'no questions answered' do
            it { is_expected.to include :incomplete_loan_questions }
          end
          context '79% of questions answered' do
            before do
              allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: 79))
            end

            it { is_expected.to include :incomplete_loan_questions }
          end
          context '80% of questions answered' do
            before do
              allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: 80))
            end

            it { is_expected.to_not include :incomplete_loan_questions }
          end
        end
        context 'and no late steps' do
          let(:loan) { create(:loan, :prospective, :with_open_project_step) }

          it { is_expected.to_not include :past_due_steps }
        end
        context 'and a step more than one day late' do
          let(:loan) { create(:loan, :prospective, :with_past_due_project_step) }

          it { is_expected.to include :past_due_steps }
        end

        context 'created 15 days ago' do
          context 'with only 14 steps' do
            let(:loan) { create(:loan, :prospective, :with_a_number_of_recent_project_steps, step_count: 14, signing_date: 16.days.ago, end_date: 1.day.ago) }

            it { is_expected.to include :sporadic_loan_updates }
          end
          context 'with 15 steps' do
            let(:loan) { create(:loan, :prospective, :with_a_number_of_recent_project_steps, step_count: 15, signing_date: 16.days.ago, end_date: 1.day.ago) }

            it { is_expected.to_not include :sporadic_loan_updates }
          end
        end

        context 'created 30+ days ago' do
          context 'with only 29 recent steps' do
            let(:loan) { create(:loan, :prospective, :with_a_number_of_recent_project_steps, step_count: 29) }

            it 'has found 29 steps' do
              expect(loan.timeline_entries.merge(ProjectStep.recent).count).to eq 29
            end
            it { is_expected.to include :sporadic_loan_updates }
          end
          context 'with only 29 recent steps and 5 old steps' do
            let(:loan) do
              create(:loan,
                :prospective,
                :with_a_number_of_recent_project_steps,
                :with_a_number_of_old_project_steps,
                step_count: 29,
                old_step_count: 5)
            end

            it 'has found 29 steps' do
              expect(loan.timeline_entries.merge(ProjectStep.recent).count).to eq 29
            end
            it { is_expected.to include :sporadic_loan_updates }
          end
          context 'with 30 recent steps' do
            let(:loan) { create(:loan, :prospective, :with_a_number_of_recent_project_steps, step_count: 30) }

            it { is_expected.to_not include :sporadic_loan_updates }
          end
        end
      end

      context 'with active loan' do
        context 'and no contract' do
          let(:loan) { create(:loan, :active) }

          it { is_expected.to include :active_without_signed_contract }
        end

        context 'and contract' do
          context 'and no logs' do
            let(:loan) { create(:loan, :active, :with_contract) }

            it { is_expected.to include :active_without_recent_logs }
          end

          context 'and no logs within 30 days' do
            let(:loan) { create(:loan, :active, :with_contract, :with_old_logs) }

            it { is_expected.to include :active_without_recent_logs }
          end

          context 'and logs within 30 days' do
            let(:loan) { create(:loan, :active, :with_contract, :with_recent_logs) }

            it { is_expected.to_not include :active_without_recent_logs }
          end
        end
      end

    end

  end
end
