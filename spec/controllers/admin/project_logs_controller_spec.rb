require 'rails_helper'

RSpec.describe Admin::ProjectLogsController, type: :controller do
  describe "create" do
    before { sign_in_admin }
    let(:attributes) { build(:project_log).attributes }

    context "with notify checked" do
      it "enqueues and sends notification email" do
        expect do
          post :create, project_log: attributes, notify: true
        end.to change { Delayed::Job.count }.by(1)
        expect do
          @dj_result = Delayed::Worker.new.work_off
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(@dj_result).to eq [1, 0] # successes, failures
      end
    end

    context "with notify unchecked" do
      it "doesn't send email" do
        expect do
          post :create, project_log: attributes, notify: false
          Delayed::Worker.new.work_off
        end.to change { ActionMailer::Base.deliveries.size }.by(0)
      end
    end
  end
end
