require 'rails_helper'

describe Accounting::QB::Connection, type: :model do
  let!(:connection) { create(:accounting_qb_connection) }


  context "unexpired and valid" do
    it "is connected" do
      expect(connection.connected?).to be true
    end
  end

  context "expired" do
    before do
      connection.update_attributes!(token_expires_at: Time.current - 1.hour)
    end
    
    it "is not connected" do
      expect(connection.connected?).to be false
    end
  end

  context "invalid" do
    before do
      connection.update_attributes!(invalid_grant: true)
    end

    it "is not connected" do
      expect(connection.connected?).to be false
    end
  end
end
