require "rails_helper"

describe TaskJob do
  let(:task) { create(:task) }

  describe "#perform" do
    subject(:operation_job) do
      Class.new(described_class) do
        def perform(operation, *args)
        end
      end
    end

    it "sets start time on " do
      subject.perform_now(operation)
      expect(operation.reload.job_started_at).not_to be_nil
    end

    context "job succeeds" do
      it "marks operation as completed" do
        subject.perform_now(operation)
        expect(operation.reload.job_completed_at).not_to be_nil
      end
    end
  end
end
