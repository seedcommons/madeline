require "rails_helper"

describe EnhancedLoanDataExport, type: :model do
  before do
    OptionSetCreator.new.create_loan_status
  end

  describe "process_data" do
    let(:division) { create(:division) }
    let!(:loan1) { create(:loan, :active, division: division) }
    let!(:loan2) { create(:loan, :active, division: division) }
    let!(:criteria) { create(:question_set, kind: "loan_criteria", division: division) }
    let(:root) { criteria.root_group }
    let(:qattrs) { {question_set: criteria, division: division} }
    let!(:q1) { create(:question, qattrs.merge(data_type: "boolean", label: "Q1")) }
    let!(:q2) { create(:question, qattrs.merge(data_type: "percentage", label: "Q2")) }
    let!(:q3) { create(:question, qattrs.merge(data_type: "text", label: "Q3")) }
    let!(:q4) { create(:question, :with_url, qattrs.merge(data_type: "range", label: "Q4")) }
    let!(:r1) do
      create(:response_set,
             question_set: criteria,
             loan: loan1,
             custom_data: {
               q1.id.to_s => {boolean: "yes", not_applicable: "no"},
               q2.id.to_s => {number: "10", not_applicable: "no"},
               q3.id.to_s => {text: "foo\nbar", not_applicable: "no"},
               q4.id.to_s => {rating: "4", text: "baz", url: "https://example.com/1", not_applicable: "no"}
             })
    end
    let!(:r2) do
      create(:response_set,
             question_set: criteria,
             loan: loan2,
             custom_data: {
               q1.id.to_s => {boolean: "", not_applicable: "yes"},
               q2.id.to_s => {number: "20", not_applicable: "no"},
               q3.id.to_s => {text: "lorp", not_applicable: "no"},
               q4.id.to_s => {rating: "", text: "", url: "", not_applicable: "yes"}
             })
    end
    let!(:export) { create(:enhanced_loan_data_export, data: nil) }

    it "should create correct data attr" do
      export.process_data
      base_headers = described_class::BASE_HEADERS
      base_headers = base_headers.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
      expect(export.data[0]).to eq(base_headers + ["Q2"])
      expect(export.data[1]).to eq(["Question ID"] + ([nil] * (base_headers.size - 1)) + [q2.id.to_s])

      row1 = ["10"]
      row2 = ["20"]
      enhanced_data = export.data[2..-1].map { |row| row[base_headers.size..-1] }
      expect(enhanced_data).to contain_exactly(row1, row2)
    end
  end
end
