require 'rails_helper'

RSpec.describe Admin::ProjectLogsController, type: :controller do
  describe "create" do
    it "enqueues and sends notification email" do
      sign_in_admin
      expect do
        post :create, project_log: build(:project_log).attributes
      end.to change { Delayed::Job.count }.by(1)
      expect do
        @dj_result = Delayed::Worker.new.work_off
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(@dj_result).to eq [1, 0] # successes, failures
    end
  end
end
