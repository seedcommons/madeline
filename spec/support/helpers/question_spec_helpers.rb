module QuestionSpecHelpers
  shared_context "question set" do
    let!(:loan_type_set) { create(:option_set, model_type: ::Loan.name, model_attribute: 'loan_type') }
    let!(:lt1) { create(:option, option_set: loan_type_set, value: 'lt1', label_translations: {en: 'Loan Type One'}) }
    let!(:lt2) { create(:option, option_set: loan_type_set, value: 'lt2', label_translations: {en: 'Loan Type Two'}) }
    let!(:loan1) { create(:loan, loan_type_value: lt1.value)}
    let!(:loan2) { create(:loan, loan_type_value: lt2.value)}
    let!(:qset) { create(:question_set, kind: 'loan_criteria') }
    let!(:root) { qset.root_group }
    let!(:rset) { create(:response_set, loan: loan1, question_set: qset) }
  end

  shared_context "full question set and responses" do
    include_context "question set"

    let!(:q1) { create_question(parent: root, name: "q1", type: "text", required: false) } # answered
    let!(:q2) { create_question(parent: root, name: "q2", type: "number", loan_types: [lt1,lt2]) }

    # Required group with subgroups
    let!(:q3) { create_group(parent: root, name: "q3", required: true) }
    let!(:q31) { create_question(parent: q3, name: "q31", type: "text", required: true, override: false) } # answered
    let!(:q32) { create_question(parent: q3, name: "q32", type: "boolean", required: true) } # answered
    let!(:q33) { create_group(parent: q3, name: "q33", required: true) }
    let!(:q331) { create_question(parent: q33, name: "q331", type: "boolean", required: false) } # answered
    let!(:q332) { create_question(parent: q33, name: "q332", type: "boolean", loan_types: [lt2]) }
    let!(:q34) { create_question(parent: q3, name: "q34", type: "text", required: false) }
    let!(:q35) { create_question(parent: q3, name: "q35", type: "text", required: true) }
    let!(:q36) { create_question(parent: q3, name: "q36", type: "text", required: true, active: false) }
    let!(:q37) { create_question(parent: q3, name: "q37", type: "text", required: true, active: false) }
    let!(:q38) { create_group(parent: q3, name: "q38", required: false) }
    let!(:q381) { create_question(parent: q38, name: "q381", type: "boolean", loan_types: []) }
    let!(:q39) { create_question(parent: q3, name: "q39", type: "text", active: false) } # answered

    # Optional group
    let!(:q4) { create_group(parent: root, name: "q4", required: false) }
    let!(:q41) { create_question(parent: q4, name: "q41", type: "text", required: false) }
    let!(:q42) { create_question(parent: q4, name: "q42", type: "boolean", required: false) } # answered
    let!(:q43) { create_question(parent: q4, name: "q43", type: "text", required: true) }
    let!(:q44) { create_question(parent: q4, name: "q44", type: "text", required: true, override: false) }

    # Inactive group
    let!(:q5) { create_group(parent: root, name: "q5", required: true, active: false) }
    let!(:q51) { create_question(parent: q5, name: "q51", type: "text", required: true) } # answered
    let!(:q52) { create_question(parent: q5, name: "q52", type: "boolean", required: false) }
    let(:node_lookup_table) { node_lookup_table_for(node) }

    before do
      create(:answer, response_set: rset, question: q1, text_data: "foo")
      create(:answer, response_set: rset, question: q2, text_data: "") # required
      create(:answer, response_set: rset, question: q31, text_data: "junk") # required
      create(:answer, response_set: rset, question: q32, boolean_data: false) # required
      create(:answer, response_set: rset, question: q331, boolean_data: true)
      create(:answer, response_set: rset, question: q39, text_data: "inactive question")
      create(:answer, response_set: rset, question: q41, text_data: "")
      create(:answer, response_set: rset, question: q42, text_data: "pants")
      create(:answer, response_set: rset, question: q43, text_data: "")
      create(:answer, response_set: rset, question: q51, text_data: "inactive group")
      rset.save!

      # Reload groups so they see their children!
      [q3, q33, q38, q4, q5].each(&:reload)
      @node
    end
  end

  def create_group(**args)
    create_question(type: "group", **args)
  end

  def lookup_table_for(node)
    @node_lookup_table ||= {}
    @node_lookup_table[node.id] = node

    node.children.each { |child| lookup_table_for(child) }
    @node_lookup_table
  end



  def create_question(set: qset, active: true, name: "", type:, override: true, required: false,
    loan_types: nil, **args)

    create(:question,
      question_set: set,
      active: active,
      data_type: type,
      override_associations: override,
      loan_types: loan_types || (required ? [lt1] : []),
      label: name,
      **args
    )
  end
end
