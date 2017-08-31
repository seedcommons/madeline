require "rails_helper"

describe RecalculateLoanHealthJob do
  let(:loan) { create(:loan, :prospective) }

  context "with existing health check object" do
    it "should work" do
      # We prove the check ran successfully by creating a contract and ensuring
      # the missing_contract field switches value.
      expect(loan.loan_health_check.missing_contract).to be true
      create(:media, media_attachable: loan, kind_value: "contract")
      described_class.new.perform(loan_id: loan.id)
      expect(loan.loan_health_check.reload.missing_contract).to be false
    end
  end
end
