require "rails_helper"

describe TaskJob do
  let(:task) { create(:task, job_class: job_class) }

  describe "#perform" do
    context "job succeeds" do
      let(:job_class) { TestJob }
      it "sets start time on task" do
        task.job_class.constantize.perform_now(task_id: task.id)
        first_start_time = task.reload.job_first_started_at
        expect(first_start_time).not_to be_nil
      end

      it "sets num_attempts on task" do
        task.job_class.constantize.perform_now(task_id: task.id)
        expect(task.reload.num_attempts).to eq 1
      end

      it "marks task as completed" do
        task.job_class.constantize.perform_now(task_id: task.id)
        expect(task.reload.job_succeeded_at).not_to be_nil
      end
    end

    context "job fails" do
      let(:job_class) { TestFailureJob }
      it "does not mark task as completed" do
        expect {task.job_class.constantize.perform_now(task_id: task.id)}.to raise_error StandardError
        pp task
        expect(task.reload.job_first_started_at).not_to be_nil
        expect(task.reload.job_succeeded_at).to be_nil
        expect(task.reload.job_last_failed_at).not_to be_nil
      end
    end
  end
end
