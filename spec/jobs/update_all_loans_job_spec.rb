require "rails_helper"

describe UpdateAllLoansJob do
  let(:task) { create(:task, job_class: UpdateAllLoansJob) }

  context "not all loans succeeded" do
    subject(:update_all_loans_job) do
      Class.new(described_class) do
        def perform(_task_data, *_args)
          task = task_for_job(self)
          handle_child_errors(task, [{"1": "test"}])
        end
      end
    end

    it "should fail and have relevant activity message" do
      expect { subject.perform_now(task_id: task.id) }.to raise_error TaskHasChildErrorsError
      expect(task.reload.status).to eq :failed
      expect(task.reload.activity_message_value).to eq "finished_with_custom_error_data"
    end
  end

  context "qb is not connected" do
    subject(:task_job) do
      Class.new(described_class) do
        def perform(_task_data, *_args)
          raise Accounting::QB::NotConnectedError
        end
      end
    end

    it "should fail and have specific activity message" do
      expect { subject.perform_now(task_id: task.id) }.to raise_error Accounting::QB::NotConnectedError
      expect(task.reload.status).to eq :failed
      expect(task.reload.activity_message_value).to eq "error_quickbooks_not_connected"
    end
  end

  context "data reset required" do
    subject(:task_job) do
      Class.new(described_class) do
        def perform(_task_data, *_args)
          raise Accounting::QB::DataResetRequiredError
        end
      end
    end

    it "should fail and have specific activity message" do
      expect { subject.perform_now(task_id: task.id) }.to raise_error Accounting::QB::DataResetRequiredError
      expect(task.reload.status).to eq :failed
      expect(task.reload.activity_message_value).to eq "error_data_reset_required"
    end
  end

  context "accounts are not set" do
    subject(:task_job) do
      Class.new(described_class) do
        def perform(_task_data, *_args)
          raise Accounting::QB::AccountsNotSelectedError
        end
      end
    end

    it "should fail and have specific activity message" do
      expect { subject.perform_now(task_id: task.id) }.to raise_error Accounting::QB::AccountsNotSelectedError
      expect(task.reload.status).to eq :failed
      expect(task.reload.activity_message_value).to eq "error_quickbooks_accounts_not_selected"
    end
  end
end
