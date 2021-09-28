class FilteredQuestionSerializer < ApplicationSerializer
  attributes :id, :name, :children, :parent_id, :division_id, :division_depth, :fieldset, :optional,
             :data_type, :required_loan_types, :inheritance_info, :active, :can_edit

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
    object.question_set.kind
  end

  def optional
    !object.required?
  end

  def required_loan_types
    object.loan_question_requirements.map { |i| i.loan_type.label.to_s }
  end

  def inheritance_info
    cmp = object.division.depth <=> object.selected_division.depth
    return nil if cmp == 0

    direction = cmp == -1 ? "ancestor" : "descendant"
    I18n.t("questions.inheritance_tag.#{direction}", division_name: object.division.name)
  end

  def can_edit
    # This is not a policy-level matter, it's a view thing. Only questions for the currently selected division
    # can be edited as a matter of good UX. A user may be allowed to edit more questions than that
    # by the policy, so this rule is more restrictive than the policy. The policy is also checked
    # at page load. So we don't check it here for efficiency's sake.
    object.division_id == object.selected_division.id
  end
end
