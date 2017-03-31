require 'rails_helper'

RSpec.describe LoanHealthCheck, type: :model do
  it 'has a valid factory' do
    expect(create(:loan_health_check)).to be_valid
  end

  context 'fresh loan' do
    let(:check) { loan.loan_health_check }
    let(:loan) { create(:loan, :prospective) }
    subject { check }

    describe '.progress_pct' do
      subject { check.progress_pct }

      context 'without criteria' do
        it 'returns 0' do
          is_expected.to eq 0
        end
      end

      context 'with criteria' do
        let(:progress) { 57 }
        before do
          allow(check).to receive(:loan).and_return(loan)
          allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: progress))
          check.recalculate
        end

        it 'matches criteria progress_pct' do
          is_expected.to eq progress
        end
      end
    end

    describe '.healthy' do
      subject { check.healthy? }

      context 'with no #health_warnings' do
        before do
          allow(check).to receive(:health_warnings).and_return([])
        end
        it { is_expected.to be true }
      end

      context 'with 1 #health_warnings' do
        before do
          allow(check).to receive(:health_warnings).and_return([:warning_one])
        end
        it { is_expected.to be false }
      end

      context 'with multiple #health_warnings' do
        before do
          allow(check).to receive(:health_warnings).and_return([:warning_one, :warning_two, :warning_three])
        end
        it { is_expected.to be false }
      end
    end

    describe '.health_warnings' do
      subject { check.health_warnings }
      before do
        check.recalculate
      end

      context 'with new loan' do
        context 'and no steps at all' do
          let(:loan) { create(:loan, :prospective) }

          context 'no questions answered' do
            it { is_expected.to include :incomplete_loan_questions }
          end

          context '79% of questions answered' do
            before do
              allow(check).to receive(:loan).and_return(loan)
              allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: 79))
              check.recalculate
            end

            it { is_expected.to include :incomplete_loan_questions }
          end

          context '80% of questions answered' do
            before do
              allow(check).to receive(:loan).and_return(loan)
              allow(loan).to receive(:criteria).and_return(instance_double(LoanResponseSet, progress_pct: 80))
              check.recalculate
            end

            it { is_expected.to_not include :incomplete_loan_questions }
          end
        end

        context 'and no late steps' do
          let(:loan) { create(:loan, :prospective, :with_open_project_step) }

          it { is_expected.to_not include :late_steps }
        end

        context 'and no end date' do
          let(:loan) { create(:loan, :prospective, end_date: nil) }

          it { is_expected.to_not include :late_steps }
        end

        context 'and a step more than one day late' do
          let(:loan) { create(:loan, :prospective, :with_past_due_project_step) }

          it { is_expected.to include :late_steps }
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
