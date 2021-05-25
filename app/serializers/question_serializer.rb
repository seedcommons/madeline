class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :name, :children, :parent_id, :fieldset, :optional, :required_loan_types, :status,
    :can_edit

  def initialize(*args, user: nil, **options)
    @user = user
    super(*args, options)
  end

  def name
    object.full_number_and_label
  end

  # jqtree expects children in a `children` key
  def children
    if object.children.present?
      # Recursively apply this serializer to children
      object.children.map { |node| self.class.new(node, user: @user) }
    end
  end

  def fieldset
    object.question_set.internal_name.sub('loan_', '')
  end

  def optional
    !object.required?
  end

  def required_loan_types
    object.loan_question_requirements.map { |i| i.loan_type.label.to_s }
  end

  def status
    object.status.presence || "active"
  end

  def can_edit
    if @user
      Pundit.policy!(@user, object).edit?
    else
      return false
    end
  end
end
