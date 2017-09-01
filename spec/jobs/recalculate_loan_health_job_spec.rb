require "rails_helper"

describe RecalculateLoanHealthJob do
  let(:loan) { create(:loan, :prospective) }

  # A health check object gets generated on before_create
  context "with existing health check object" do
    it "should regenerate the check" do
      # We prove the check ran successfully by creating a contract and ensuring
      # the missing_contract field switches value.
      expect(loan.health_check.missing_contract).to be true
      create(:media, media_attachable: loan, kind_value: "contract")
      described_class.new.perform(loan_id: loan.id)
      expect(loan.reload.health_check.missing_contract).to be false
    end
  end

  context "without existing health check object" do
    before do
      loan.health_check.destroy
    end

    it "should create and regenerate the check" do
      expect(loan.health_check).to be_destroyed
      create(:media, media_attachable: loan, kind_value: "contract")
      described_class.new.perform(loan_id: loan.id)
      expect(loan.reload.health_check.missing_contract).to be false
    end
  end

  # Loan could get deleted between when job is enqueued and when it is run.
  context "for non-existent loan" do
    it "should do nothing and not raise error" do
      described_class.new.perform(loan_id: 1234567)
    end
  end
end
