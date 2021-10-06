require "rails_helper"

describe LogNotificationJob do
  context "has errors on some loans" do
    let(:division1) { create(:division) }
    let(:division2) { create(:division) }
    let!(:person1) { create(:person, :with_member_access, :with_password, division: division1) }
    let!(:person2) { create(:person, :with_member_access, :with_password, division: division1) }
    let!(:decoy) { create(:person, :with_member_access, :with_password, division: division2) }
    let(:log) { create(:project_log, division: division1) }
    let(:deliveries) { ActionMailer::Base.deliveries }

    context "with division having notifications on" do
      let(:division1) { create(:division, notify_on_new_logs: true) }

      it "sends emails to correct users" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(2)
        expect(deliveries[-2..-1].flat_map(&:to)).to match_array([person1, person2].map(&:email))
      end
    end

    context "with division having notifications off" do
      let(:division1) { create(:division, notify_on_new_logs: false) }

      it "sends no emails" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(0)
      end
    end
  end
end
