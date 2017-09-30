module QuestionSpecHelpers
  shared_context "question set" do
    let!(:loan_type_set) { create(:option_set, model_type: ::Loan.name, model_attribute: 'loan_type') }
    let!(:lt1) { create(:option, option_set: loan_type_set, value: 'lt1', label_translations: {en: 'Loan Type One'}) }
    let!(:lt2) { create(:option, option_set: loan_type_set, value: 'lt2', label_translations: {en: 'Loan Type Two'}) }
    let!(:loan1) { create(:loan, loan_type_value: lt1.value)}
    let!(:loan2) { create(:loan, loan_type_value: lt2.value)}
    let!(:qset) { create(:loan_question_set, internal_name: 'loan_criteria') }
    let!(:root) { qset.root_group }
    let(:rset) { build(:loan_response_set, loan: loan1) }

    before { rset.current_user = create(:user, :admin) }
  end

  shared_context "full question set and responses" do
    include_context "question set"

    let!(:q1) { create_question(parent: root, name: "q1", type: "text", required: false) } # answered
    let!(:q2) { create_question(parent: root, name: "q2", type: "number", loan_types: [lt1,lt2]) }

    # Required group with subgroups
    let!(:q3) { create_group(parent: root, name: "q3", required: true) }
    let!(:q31) { create_question(parent: q3, name: "q31", type: "string", required: true, override: false) } # answered
    let!(:q32) { create_question(parent: q3, name: "q32", type: "boolean", required: true) } # answered
    let!(:q33) { create_group(parent: q3, name: "q33", required: true, position: 99) }
    let!(:q331) { create_question(parent: q33, name: "q331", type: "boolean", required: false) } # answered
    let!(:q332) { create_question(parent: q33, name: "q332", type: "boolean", loan_types: [lt2]) }
    let!(:q34) { create_question(parent: q3, name: "q34", type: "string", required: false) }
    let!(:q35) { create_question(parent: q3, name: "q35", type: "string", required: true, position: -99) }
    let!(:q36) { create_question(parent: q3, name: "q36", type: "string", required: true, status: 'inactive') }
    let!(:q37) { create_question(parent: q3, name: "q37", type: "string", required: true, status: 'retired') } # answered
    let!(:q38) { create_group(parent: q3, name: "q38", required: false) }
    let!(:q381) { create_question(parent: q38, name: "q381", type: "boolean", loan_types: []) }
    let!(:q39) { create_question(parent: q3, name: "q39", type: "text", status: 'inactive') } # answered

    # Optional group
    let!(:q4) { create_group(parent: root, name: "q4", required: false) }
    let!(:q41) { create_question(parent: q4, name: "q41", type: "string", required: false) }
    let!(:q42) { create_question(parent: q4, name: "q42", type: "boolean", required: false) } # answered
    let!(:q43) { create_question(parent: q4, name: "q43", type: "string", required: true) }
    let!(:q44) { create_question(parent: q4, name: "q44", type: "string", required: true, override: false) }

    # Inactive group
    let!(:q5) { create_group(parent: root, name: "q5", required: true, status: 'inactive') }
    let!(:q51) { create_question(parent: q5, name: "q51", type: "string", required: true) } # answered
    let!(:q52) { create_question(parent: q5, name: "q52", type: "boolean", required: false) }

    # Retired group
    let!(:q6) { create_group(parent: root, name: "q6", required: true, status: 'retired') }
    let!(:q61) { create_question(parent: q6, name: "q61", type: "string", required: false) } # answered
    let!(:q62) { create_question(parent: q6, name: "q62", type: "boolean", required: true, status: 'inactive') }

    before do
      rset.current_user = create(:user, :admin)
      rset.set_response(q1, {"text" => "foo"})
      rset.set_response(q2, {"text" => ""}) # required
      rset.set_response(q31, {"text" => "junk"}) # required
      rset.set_response(q32, {"boolean" => "no"}) # required
      rset.set_response(q331, {"boolean" => "yes"})
      rset.set_response(q37, {"text" => "retired question"})
      rset.set_response(q39, {"text" => "inactive question"})
      rset.set_response(q41, {"text" => ""})
      rset.set_response(q42, {"text" => "pants"})
      rset.set_response(q43, {"text" => ""})
      rset.set_response(q51, {"text" => "inactive group"})
      rset.set_response(q61, {"text" => "retired group"})
      rset.save!

      # Reload groups so they see their children!
      [q3, q33, q38, q4, q5, q6].each(&:reload)
    end
  end

  def create_group(**args)
    create_question(type: "group", **args)
  end

  def create_question(set: qset, status: 'active', name: "", type:, override: true, required: false,
    loan_types: nil, **args)

    create(:loan_question,
      loan_question_set: set,
      status: status,
      internal_name: name,
      data_type: type,
      override_associations: override,
      loan_types: loan_types || (required ? [lt1] : []),
      **args
    )
  end
end
