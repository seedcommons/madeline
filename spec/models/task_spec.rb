require 'rails_helper'

describe Task, :type => :model do

  describe "#enqueue" do
    let(:task) { create(:task, job_class: RecalculateLoanHealthJob) }
    it "creates a job and stores initial information" do
      task.enqueue
      task.reload
      expect(task.provider_job_id).not_to be_nil
      expect(task.status).to eq :pending
    end
  end
end
