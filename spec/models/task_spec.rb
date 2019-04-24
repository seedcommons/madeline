# == Schema Information
#
# Table name: tasks
#
#  activity_message_value    :string(65536)    not null
#  id                        :bigint(8)        not null, primary key
#  job_class                 :string(255)      not null
#  job_completed_at          :datetime
#  job_enqueued_for_retry_at :datetime
#  job_failed_at             :datetime
#  job_started_at            :datetime
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
end
