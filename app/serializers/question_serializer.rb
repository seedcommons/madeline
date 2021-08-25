class QuestionSerializer < ApplicationSerializer
  attributes :id, :name, :children, :parent_id, :fieldset, :optional, :required_loan_types, :active, :can_edit

  attr_accessor :selected_division

  def initialize(*args, selected_division:, **options)
    self.selected_division = selected_division
    super(*args, options)
  end

  def name
    object.full_number_and_label
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.map { |node| self.class.new(node, selected_division: selected_division) }
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
    object.division_id == selected_division.id
  end
end
