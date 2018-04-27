require 'rails_helper'

RSpec.describe Admin::ProjectLogsController, type: :controller do
  describe "create" do
    before do
      @user = create(:person, :with_admin_access).user
      sign_in(@user)
      @user.division.people << create(:person, :with_admin_access)
    end

    let(:log) { build(:project_log) }

    context "with division set to notify" do
      before { log.division.update(notify_on_new_logs: true) }

      context "with notify checked" do
        it "enqueues and sends notification email" do
          expect do
            post :create, params: {project_log: log.attributes, notify: '1'}
            Delayed::Worker.new.work_off
          end.to change { ActionMailer::Base.deliveries.size }.by(2)
        end
      end

      context "with notify unchecked" do
        it "doesn't send email" do
          expect do
            post :create, params: {project_log: log.attributes}
            Delayed::Worker.new.work_off
          end.to change { ActionMailer::Base.deliveries.size }.by(0)
        end
      end
    end

    context "with division not set to notify" do
      it "doesn't send email" do
        expect do
          post :create, params: {project_log: log.attributes, notify: '1'}
          Delayed::Worker.new.work_off
        end.to change { ActionMailer::Base.deliveries.size }.by(0)
      end
    end
  end
end
