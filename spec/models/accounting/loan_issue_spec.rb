require "rails_helper"

describe Accounting::LoanIssue do
  it "has a valid factory" do
    create(:accounting_loan_issue)
  end

  describe "scopes" do
    let(:loan) { create(:loan) }
    let!(:issue1) { create(:accounting_loan_issue, loan: nil, level: :warning) }
    let!(:issue2) { create(:accounting_loan_issue, loan: loan, level: :error) }

    it "are correct" do
      expect(described_class.for_loan_or_global(loan)).to contain_exactly(issue1, issue2)
      expect(described_class.for_loan(loan)).to contain_exactly(issue2)
      expect(described_class.global).to contain_exactly(issue1)
      expect(described_class.warning).to contain_exactly(issue1)
      expect(described_class.error).to contain_exactly(issue2)
    end
  end
end
