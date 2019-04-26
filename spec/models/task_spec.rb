# == Schema Information
#
# Table name: tasks
#
#  activity_message_value    :string(65536)    not null
#  id                        :bigint(8)        not null, primary key
#  job_class                 :string(255)      not null
#  job_dead                  :boolean          default(FALSE), not null
#  job_enqueued_for_retry_at :datetime
#  job_last_failed_at        :datetime
#  job_started_at            :datetime
#  job_succeeded_at          :datetime
#  job_type_value            :string(255)      not null
#  provider_job_id           :string
#

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

  describe "#status" do

    context "not started" do
      let(:task) { create(:task, provider_job_id: 1 ) }
      it "should be pending" do
        expect(task.status).to eq :pending
      end
    end

    context "started but not completed, failed, or stalled" do
      let(:task) { create(:task, provider_job_id: 1, job_started_at: Time.current) }
      it "should be in_progress" do
        expect(task.status).to eq :in_progress
      end
    end

    context "has completed successfully" do
      let(:task) { create(:task, provider_job_id: 1, job_started_at: Time.current - 1.minute, job_succeeded_at: Time.current) }
      it "should be succeeded" do
        expect(task.status).to eq :succeeded
      end
    end

    context "has started, failed and enqueued for retry" do
      let(:task) { create(:task,
        provider_job_id: 1,
        job_started_at: Time.current - 1.minute,
        job_last_failed_at: Time.current - 1.second,
        job_enqueued_for_retry_at: Time.current
      ) }

      it "should be stalled" do
        expect(task.status).to eq :stalled
      end
    end
  end
end
