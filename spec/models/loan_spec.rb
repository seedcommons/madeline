require 'rails_helper'

describe Loan, type: :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'media_attachable'
  it_should_behave_like 'option_settable', ['status', 'loan_type', 'public_level']

  it 'has a valid factory' do
    expect(create(:loan)).to be_valid
  end

  it 'does not save without a division' do
    expect {
      create(:loan, division: nil)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'primary and secondary agents' do
    include_context 'project'

    it 'raises error if agents are the same' do
      error = 'The point person for this project cannot be the same as the second point person'
      expect(p_1).not_to be_valid
      expect(p_1.errors[:primary_agent].join).to match(error)
    end

    it 'does not raise error for different agents' do
      expect(p_2).to be_valid
    end
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

      # JE todo: confirm if this logic is  still relevant
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
      let(:loan) { create(:loan, signing_date: Date.civil(2011, 11, 11)) }
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
        option_set.options.create(value: 'active', label_translations: {en: 'Active'})
        option_set.options.create(value: 'completed', label_translations: {en: 'Completed'})
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

    describe '.health_check' do
      context 'for new loan' do
        it 'creates a LoanHealthCheck' do
          expect(loan.health_check).to_not be nil
        end
      end

      context 'existing loan' do
        before do
          # creating the loan enqueues RecalculateLoanHealthJob, so need to do it outside of the spec
          loan
        end
        context 'update to field other than updated_at' do
          it 'enqueues loan health check' do
            ActiveJob::Base.queue_adapter = :test
            expect { loan.update(projected_end_date: Time.zone.today) }.to have_enqueued_job(RecalculateLoanHealthJob)
          end
        end

        context 'touch' do
          # loan.touch is used in transaction model when importing qb txns
          # this only updates updated_at attr and should not trigger loan health check
          it 'does not enqueue loan health check' do
            ActiveJob::Base.queue_adapter = :test
            expect { loan.touch }.not_to have_enqueued_job(RecalculateLoanHealthJob)
          end
        end
      end
    end

    describe '.healthy?' do
      context 'without health_check record' do
        it 'is not healthy' do
          loan.health_check = nil

          expect(loan.health_check).to be nil
          expect(loan.healthy?).to be false
        end
      end
    end

    describe 'calculated fields: .sum_of_repayments, .sum_of_disbursements, .change_in_interest, .change_in_principal' do
      context "no transactions" do
        it "returns nil" do
          expect(loan.sum_of_disbursements).to be_nil
          expect(loan.sum_of_repayments).to be_nil
          expect(loan.change_in_interest).to be_nil
          expect(loan.change_in_principal).to be_nil
        end
      end

      context "multiple transactions" do
        let(:export) {
          create(:standard_loan_data_export, data: nil)
        }
        let(:loan) { create(:loan, :active, rate: 3.0) }
        # dollar amounts in these transactions are not realistic
        let!(:t0) {
          create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 10.0,
                                          project: loan, txn_date: "2019-01-01", change_in_interest: 0.10, change_in_principal: 11)
        }
        let!(:t1) {
          create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 20.0,
                                          project: loan, txn_date: "2019-01-02", change_in_interest: -0.20, change_in_principal: -12)
        }
        let!(:t2) {
          create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 30.0,
                                          project: loan, txn_date: "2019-01-03", change_in_interest: 0.30, change_in_principal: 13)
        }
        let!(:t3) {
          create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 40.0,
                                          project: loan, txn_date: "2019-01-04", change_in_interest: -0.40, change_in_principal: -14)
        }
        let!(:t4) {
          create(:accounting_transaction, loan_transaction_type_value: "disbursement", amount: 50.0,
                                          project: loan, txn_date: "2019-01-05", change_in_interest: 0.50, change_in_principal: 15)
        }
        let!(:t5) {
          create(:accounting_transaction, loan_transaction_type_value: "repayment", amount: 60.0,
                                          project: loan, txn_date: "2019-01-06", change_in_interest: -0.60, change_in_principal: -16)
        }

        it "returns sum of that type of transaction only" do
          expect(loan.sum_of_disbursements).to eq 90
          expect(loan.sum_of_repayments).to eq 120
        end

        it "limit by date, inclusive" do
          expect(loan.sum_of_disbursements(start_date: Date.parse('2019-01-04'))).to eq 50
          expect(loan.sum_of_repayments(start_date: Date.parse('2019-01-04'))).to eq 100
          expect(loan.sum_of_disbursements(start_date: Date.parse('2019-01-03'), end_date: Date.parse('2019-01-05'))).to eq 80
          expect(loan.sum_of_repayments(start_date: Date.parse('2019-01-03'), end_date: Date.parse('2019-01-05'))).to eq 40
          expect(loan.sum_of_disbursements(end_date: Date.parse('2019-01-05'))).to eq 90
          expect(loan.sum_of_repayments(end_date: Date.parse('2019-01-05'))).to eq 60
          expect(loan.change_in_interest(start_date: Date.parse('2019-01-03'))).to eq(-0.2)
          expect(loan.change_in_principal(start_date: Date.parse('2019-01-03'))).to eq(-2)
          expect(loan.change_in_interest(start_date: Date.parse('2019-01-03'), end_date: Date.parse('2019-01-05'))).to eq 0.4
          expect(loan.change_in_principal(start_date: Date.parse('2019-01-03'), end_date: Date.parse('2019-01-05'))).to eq 14
          expect(loan.change_in_interest(end_date: Date.parse('2019-01-05'))).to eq 0.3
          expect(loan.change_in_principal(end_date: Date.parse('2019-01-05'))).to eq 13
        end

        it "raises error if at least one transaction has nil value for change_in_interest" do
          t4.update(change_in_interest: nil)
          expect { loan.change_in_interest(start_date: Date.parse('2019-01-01')) }.to raise_error(Accounting::TransactionDataMissingError, I18n.t("loan.errors.transaction_data_missing"))
        end
      end
    end

    describe 'default quickbooks customer for transaction' do
      let(:customer_a) { create(:customer) }
      let(:customer_b) { create(:customer) }
      let(:new_transaction) { build(:accounting_transaction, loan_transaction_type_value: :interest) }

      context "existing txns of same type with a customer" do
        let!(:txn_1) { create(:accounting_transaction, project: loan, customer: customer_b, txn_date: Time.zone.today - 2.days, loan_transaction_type_value: :interest) }
        let!(:txn_2) { create(:accounting_transaction, project: loan, customer: customer_a, txn_date: Time.zone.today - 1.day, loan_transaction_type_value: :interest) }
        let!(:txn_3) { create(:accounting_transaction, project: loan, customer: customer_b, txn_date: Time.zone.today, loan_transaction_type_value: :other) }
        it 'assigns customer that most recent txn of same type has' do
          expect(loan.default_accounting_customer_for_transaction(new_transaction)).to eql customer_a
        end
      end

      context "existing txns only of a different type" do
        let!(:txn_1) { create(:accounting_transaction, project: loan, customer: customer_b, txn_date: Time.zone.today - 3.days, loan_transaction_type_value: :disbursement) }
        let!(:txn_2) { create(:accounting_transaction, project: loan, customer: customer_a, txn_date: Time.zone.today - 2.days, loan_transaction_type_value: :repayment) }
        let!(:txn_3) { create(:accounting_transaction, project: loan, customer: customer_b, txn_date: Time.zone.today - 1.day, loan_transaction_type_value: :other) }
        it 'assigns customer that most recent txn of repayment or disbursement type that has a customer' do
          expect(loan.default_accounting_customer_for_transaction(new_transaction)).to eql customer_a
        end
      end

      context "no repayment, disbursement, or same type txns on loan but loans organization matches a customer" do
        let!(:txn) { create(:accounting_transaction, project: loan, customer: customer_b, txn_date: Time.zone.today - 1.day, loan_transaction_type_value: :other) }
        let!(:customer_match) { create(:customer, name: loan.organization.name) }
        it "returns customer with matching name" do
          expect(loan.default_accounting_customer_for_transaction(new_transaction)).to eql customer_match
        end
      end

      context "no txns on loan and loan organization does not match a customer" do
        it "returns nil" do
          expect(loan.default_accounting_customer_for_transaction(new_transaction)).to eql nil
        end
      end
    end
  end
end
