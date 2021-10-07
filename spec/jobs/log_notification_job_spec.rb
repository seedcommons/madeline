require "rails_helper"

describe LogNotificationJob do
  let(:division) { create(:division, notify_on_new_logs: true) }
  let(:subdivision) { create(:division, parent: division, notify_on_new_logs: true) }
  let(:decoy_division) { create(:division) }
  let(:notification_source) { "home_only" }
  let!(:person1) { create(:person, :with_member_access, :with_password, division: division) }
  let!(:person2) { create(:person, :with_member_access, :with_password, division: division) }
  let!(:decoy1) { create(:person, :with_member_access, :with_password, division: decoy_division) }
  let!(:decoy2) { create(:person, :with_member_access, :with_password, division: division) }
  let!(:decoy3) { create(:person, :with_member_access, :with_password, division: division) }
  let(:log) { create(:project_log, division: log_division) }
  let(:deliveries) { ActionMailer::Base.deliveries }

  before do
    [person1, person2, decoy2].each { |p| p.user.update!(notification_source: notification_source) }
    decoy2.update!(has_system_access: false)
    decoy3.user.update!(notification_source: "none")
  end

  context "when log is on main division" do
    let(:log_division) { division }

    context "with division having notifications on" do
      it "sends emails to correct users" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(2)
        expect(deliveries[-2..-1].flat_map(&:to)).to match_array([person1, person2].map(&:email))
      end
    end

    context "with division having notifications off" do
      let(:division) { create(:division, notify_on_new_logs: false) }

      it "sends no emails" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(0)
      end
    end
  end

  context "when log is on subdivision" do
    let(:log_division) { subdivision }

    context "when user has notification_source home_only" do
      it "sends no emails" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(0)
      end
    end

    context "when user has notification_source home_and_sub" do
      let(:notification_source) { "home_and_sub" }

      it "sends emails" do
        expect { described_class.perform_now(log) }.to change { deliveries.size }.by(2)
      end
    end
  end
end
