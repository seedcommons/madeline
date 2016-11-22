class LoanQuestionSerializer < ActiveModel::Serializer
  attributes :id, :name, :children, :parent_id, :fieldset, :optional, :required_loan_types

  def initialize(*args, loan: nil, **options)
    @loan = loan
    super(*args, options)
  end

  def name
    object.label.to_s
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children_applicable_to(@loan).map { |node| self.class.new(node, loan: @loan) }
    end
  end

  def fieldset
    object.loan_question_set.internal_name.sub('loan_', '')
  end

  def optional
    @loan && !object.required_for?(@loan)
  end

  def required_loan_types
    # TODO: Compile list of loan_types and labels. At minimum an array of labels is needed.
    loan_types = []

    object.loan_question_requirements.each do |loan_type|
      lt_id = loan_type.option_id
      lt_label = Option.find(lt_id).label
      loan_types << lt_label
    end
  end
end
