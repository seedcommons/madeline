require 'rails_helper'

RSpec.describe Admin::ProjectLogsController, type: :controller do
  describe "create" do
    it "enqueues notification email" do
      expect do
        post :create, build(:project_log).attributes
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
