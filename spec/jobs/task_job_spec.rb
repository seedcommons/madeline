require "rails_helper"

describe TaskJob do
  let(:task) { create(:task, job_class: Class) }

  describe "#perform" do
    context "job succeeds" do
      subject(:task_job) do
        Class.new(described_class) do
          def perform(task_data, *args)
          end
        end
      end

      it "task is started" do
        # use expect any instance of because the task is necessarily reloaded from db in the job callback
        expect_any_instance_of(Task).to receive(:start)
        subject.perform_now(task_id: task.id)
      end

      it "task succeeds" do
        subject.perform_now(task_id: task.id)
        expect(task.reload.status).to eq :succeeded
      end
    end

    context "job fails" do
      subject(:task_job) do
        Class.new(described_class) do
          def perform(_task_data, *args)
            raise StandardError
          end
        end
      end
      it "records failure" do
        expect_any_instance_of(Task).to receive(:record_failure)
        expect { subject.perform_now(task_id: task.id) }.to raise_error StandardError
      end
    end
  end
end
