require "rails_helper"

describe EnhancedLoanDataExport, type: :model do
  before do
    OptionSetCreator.new.create_loan_status
  end

  describe "process_data" do
    let(:division) { create(:division) }
    let(:subdivision) { create(:division, parent: division) }
    let!(:loan1) { create(:loan, :active, division: division) }
    let!(:loan2) { create(:loan, :active, division: subdivision) }
    let!(:loan3) { create(:loan, :active, division: division) }

    let(:base_headers) do
      StandardLoanDataExport::HEADERS.map { |h| I18n.t("standard_loan_data_exports.headers.#{h}") }
    end
    let(:id_row_nils) { [nil] * (base_headers.size - 1) }
    let(:response_data) { export.data[2..-1].map { |row| row[base_headers.size..-1] } }

    # Decoy question set, should not appear anywhere.
    let(:decoy_division) { create(:division) }
    let(:decoy_question_set) { create(:question_set, kind: "loan_criteria", division: decoy_division) }
    let(:decoy_question_set) { create(:question_set, kind: "loan_criteria", division: decoy_division) }
    let(:qdattrs) { {question_set: decoy_question_set, division: decoy_division} }
    let!(:qd1) { create(:question, qdattrs.merge(data_type: "number", label: "QD1")) }

    let(:export) { create(:enhanced_loan_data_export, division: division, data: nil) }

    context "with criteria question set" do
      let!(:criteria) { create(:question_set, kind: "loan_criteria", division: division) }
      let(:qcattrs) { {question_set: criteria, division: division} }
      let!(:qc1) { create(:question, qcattrs.merge(data_type: "boolean", label: "QC1")) }
      let!(:qc2) { create(:question, qcattrs.merge(data_type: "percentage", label: "QC2")) }
      let!(:qc3) { create(:question, qcattrs.merge(data_type: "text", label: "QC3")) }
      let!(:qc4) { create(:question, qcattrs.merge(data_type: "range", label: "QC4")) }


      # This question is on a subdivision, should still be included.
      let!(:qc5) do
        create(:question, :with_url, qcattrs.merge(division: subdivision, data_type: "range", label: "QC5"))
      end

      let!(:r1_c) do
        create(:response_set,
               question_set: criteria,
               loan: loan1)
      end
      let!(:r1_c_a1) { create(:answer, question: qc1, response_set: r1_c,  boolean_data: true, not_applicable: false) }
      let!(:r1_c_a2) { create(:answer, question: qc2, response_set: r1_c, numeric_data: 10, not_applicable: false) }
      let!(:r1_c_a3) { create(:answer, question: qc3, response_set: r1_c, text_data: "foo\nbar", not_applicable: false) }
      let!(:r1_c_a4) { create(:answer, question: qc4, response_set: r1_c, numeric_data: "4", text_data: "text", not_applicable: false) }
      let!(:r2_c) do
        create(:response_set,
               question_set: criteria,
               loan: loan2)
      end
      let!(:r2_c_a1) { create(:answer, question: qc1, response_set: r2_c, boolean_data: nil, not_applicable: true) }
      let!(:r2_c_a2) { create(:answer, question: qc2, response_set: r2_c, numeric_data: 11, not_applicable: false) }
      let!(:r2_c_a3) { create(:answer, question: qc3, response_set: r2_c, text_data: "lorp", not_applicable: false) }
      let!(:r2_c_a4) { create(:answer, question: qc4, response_set: r2_c, numeric_data: nil, text_data: nil, not_applicable: true) }
      let!(:r2_c_a5) { create(:answer, question: qc5, response_set: r2_c, numeric_data: 5, linked_document_data: {url: "https://example.com/1"}, not_applicable: false) }

      it "should create correct data attr" do
        export.process_data
        expect(export.data[0]).to eq(base_headers + ["QC1", "QC2", "QC3", "QC4", "QC5"])
        expect(export.data[1]).to eq(["Question ID"] + id_row_nils + [qc1, qc2, qc3, qc4, qc5].map(&:id))

        row1 = ["yes", "10", "foo\nbar", "4"]
        row2 = [nil, "11", "lorp", nil, "5"]
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
                 loan: loan1)
        end
        let!(:r1_p_q1) { create(:answer, question: qp1, response_set: r1_p, numeric_data: 7, not_applicable: false)}
        let!(:r3_p) do
          create(:response_set,
                 question_set: post_analysis,
                 loan: loan3)
        end
        let!(:r3_p_q1) { create(:answer, question: qp1, response_set: r3_p, numeric_data: 99.9, not_applicable: false)}

        it "should create correct data attr" do
          export.process_data
          expect(export.data[0]).to eq(base_headers + ["QC1", "QC2", "QC3", "QC4", "QC5", "QP1"])
          expect(export.data[1]).to eq(["Question ID"] + id_row_nils + [qc1, qc2, qc3, qc4, qc5, qp1].map(&:id))

          row1 = ["yes", "10", "foo\nbar", "4", nil, "7"]
          row2 = [nil, "11", "lorp", nil, "5"]
          row3 = [nil, nil, nil, nil, nil, "99.9"]
          expect(response_data).to contain_exactly(row1, row2, row3)
        end
      end
    end

    context "when subdivision has own question set" do
      let!(:setA) { create(:question_set, kind: "loan_criteria", division: division) }
      let(:qaattrs) { {question_set: setA, division: division} }
      let!(:qa1) { create(:question, qaattrs.merge(data_type: "number", label: "QA1")) }
      let!(:qa2) { create(:question, qaattrs.merge(data_type: "number", label: "QA2")) }

      let!(:setB) { create(:question_set, kind: "loan_criteria", division: subdivision) }
      let(:qbattrs) { {question_set: setB, division: subdivision} }
      let!(:qb1) { create(:question, qbattrs.merge(data_type: "number", label: "QB1")) }

      let!(:r1) do
        create(:response_set,
               question_set: setA,
               loan: loan1)
      end
      let!(:r1_a1) { create(:answer, question: qa1, response_set: r1, numeric_data: 5, not_applicable: false) }
      let!(:r1_a2) { create(:answer, question: qa2, response_set: r1, numeric_data: 10, not_applicable: false) }
      let!(:r2) do
        create(:response_set,
               question_set: setB,
               loan: loan2)
      end
      let!(:r2_a1) { create(:answer, question: qb1, response_set: r2, numeric_data: 15, not_applicable: false) }
      it "should include data from both questions sets" do
        export.process_data
        expect(export.data[0]).to eq(base_headers + ["QA1", "QA2", "QB1"])
        expect(export.data[1]).to eq(["Question ID"] + id_row_nils + [qa1, qa2, qb1].map(&:id))
        row1 = ["5", "10"]
        row2 = [nil, nil, "15"]
        row3 = []
        expect(response_data).to contain_exactly(row1, row2, row3)
      end
    end
  end
end
