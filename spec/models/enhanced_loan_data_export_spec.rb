require "rails_helper"

describe EnhancedLoanDataExport, type: :model do
  before do
    OptionSetCreator.new.create_loan_status
  end

  describe "process_data" do
    let(:division) { create(:division) }
    let!(:loan1) { create(:loan, :active, division: division) }
    let!(:loan2) { create(:loan, :active, division: division) }
    let!(:loan3) { create(:loan, :active, division: division) }
    let(:base_headers) do
      StandardLoanDataExport::HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
    end
    let(:id_row_nils) { [nil] * (base_headers.size - 1) }
    let(:response_data) { export.data[2..-1].map { |row| row[base_headers.size..-1] } }
    let(:export) { create(:enhanced_loan_data_export, data: nil) }

    context "with criteria question set" do
      let!(:criteria) { create(:question_set, kind: "loan_criteria", division: division) }
      let(:qcattrs) { {question_set: criteria, division: division} }
      let!(:qc1) { create(:question, qcattrs.merge(data_type: "boolean", label: "QC1")) }
      let!(:qc2) { create(:question, qcattrs.merge(data_type: "percentage", label: "QC2")) }
      let!(:qc3) { create(:question, qcattrs.merge(data_type: "text", label: "QC3")) }
      let!(:qc4) { create(:question, :with_url, qcattrs.merge(data_type: "rating", label: "QC4")) }

      let!(:r1_c) do
        create(:response_set,
               question_set: criteria,
               loan: loan1,
               custom_data: {
                 qc1.id.to_s => {boolean: "yes", not_applicable: "no"},
                 qc2.id.to_s => {number: "10", not_applicable: "no"},
                 qc3.id.to_s => {text: "foo\nbar", not_applicable: "no"},
                 qc4.id.to_s => {rating: "4", url: "https://example.com/1", not_applicable: "no"}
               })
      end
      let!(:r2_c) do
        create(:response_set,
               question_set: criteria,
               loan: loan2,
               custom_data: {
                 qc1.id.to_s => {boolean: "", not_applicable: "yes"},
                 qc2.id.to_s => {number: "20", not_applicable: "no"},
                 qc3.id.to_s => {text: "lorp", not_applicable: "no"},
                 qc4.id.to_s => {rating: "", url: "", not_applicable: "yes"}
               })
      end

      it "should create correct data attr" do
        export.process_data
        expect(export.data[0]).to eq(base_headers + ["QC2", "QC4"])
        expect(export.data[1]).to eq(["Question ID"] + id_row_nils + [qc2, qc4].map(&:id))

        row1 = ["10", "4"]
        row2 = ["20", ""]
        row3 = []
        expect(response_data).to contain_exactly(row1, row2, row3)
      end

      context "with criteria and post_analysis" do
        let!(:post_analysis) { create(:question_set, kind: "loan_post_analysis", division: division) }
        let(:qpattrs) { {question_set: post_analysis, division: division} }
        let!(:qp1) { create(:question, :with_url, qpattrs.merge(data_type: "number", label: "QP1")) }
        let!(:r1_p) do
          create(:response_set,
                 question_set: post_analysis,
                 loan: loan1,
                 custom_data: {
                   qp1.id.to_s => {number: "7", not_applicable: "no"}
                 })
        end
        let!(:r3_p) do
          create(:response_set,
                 question_set: post_analysis,
                 loan: loan3,
                 custom_data: {
                   qp1.id.to_s => {number: "99.9", not_applicable: "no"}
                 })
        end

        it "should create correct data attr" do
          export.process_data
          expect(export.data[0]).to eq(base_headers + ["QC2", "QC4", "QP1"])
          expect(export.data[1]).to eq(["Question ID"] + id_row_nils + [qc2, qc4, qp1].map(&:id))

          row1 = ["10", "4", "7"]
          row2 = ["20", ""]
          row3 = [nil, nil, "99.9"]
          expect(response_data).to contain_exactly(row1, row2, row3)
        end
      end
    end
  end
end
