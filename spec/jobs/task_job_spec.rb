require "rails_helper"

describe TaskJob do
  let(:task) { create(:task, job_class: job_class) }

  describe "#perform" do
    context "job succeeds" do
      let(:job_class) { TestJob }
      it "task is started" do
        # use expect any instance of because the task is necessarily reloaded from db in the job callback
        expect_any_instance_of(Task).to receive(:start)
        task.job_class.constantize.perform_now(task_id: task.id)
      end

      it "task succeeds" do
        task.job_class.constantize.perform_now(task_id: task.id)
        expect(task.reload.status).to eq :succeeded
      end
    end

    context "job fails" do
      let(:job_class) { TestFailureJob }
      it "records failure" do
        expect_any_instance_of(Task).to receive(:record_failure)
        expect {task.job_class.constantize.perform_now(task_id: task.id)}.to raise_error StandardError
      end
    end
  end
end
