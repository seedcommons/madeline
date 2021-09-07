class FilteredQuestionSerializer < ApplicationSerializer
  attributes :id, :name, :children, :parent_id, :division_id, :division_depth, :fieldset, :optional,
             :data_type, :required_loan_types, :active, :can_edit

  def initialize(*args, **options)
    super(*args, options)
  end

  def name
    object.full_number_and_label
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.map { |node| self.class.new(node) }
    end
  end

  def fieldset
    object.question_set.internal_name.sub("loan_", "")
  end

  def optional
    !object.required?
  end

  def required_loan_types
    object.loan_question_requirements.map { |i| i.loan_type.label.to_s }
  end

  def can_edit
    # This is not a policy-level matter, it's a view thing. Only questions for the currently selected division
    # can be edited as a matter of good UX. A user may be allowed to edit more questions than that
    # by the policy, so this rule is more restrictive than the policy. The policy is also checked
    # at page load. So we don't check it here for efficiency's sake.
    object.division_id == object.selected_division.id
  end
end
