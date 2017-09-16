# Inherits from FilteredQuestion. Adds a Loan and provides methods relating to the combination of the two.
class LoanFilteredQuestion < FilteredQuestion
  attr_accessor :loan

  def initialize(question, loan:)
    super(question, loan: loan)
    @loan = loan
  end

  # Returns child questions that are applicable to the given loan. Sorts by requiredness, then position.
  def children
    @children ||= decorated_children.select(&:visible?).sort_by do |i|
      [i.required? ? 1 : 2, i.position]
    end
  end

  # Resolves if this particular question is considered required for the provided loan, based on
  # presence of association records in the loan_questions_options relation table, and the
  # 'override_associations' flag.
  # - If override is true and join records are present, question is required for those loan types
  #   and optional for all others
  # - If override is true and no records are present, all are optional
  # - If override is false, inherit from parent
  # - Top level nodes (those with depth = 1 are direct children of the root) effectively have
  #   override always true
  # Note, loan type association records are ignored for questions without the 'override_assocations'
  # flag assigned.
  def required?
    @required ||= if override_associations || depth == 1
      loan_types.include?(loan.loan_type_option)
    else
      root? ? true : parent.required?
    end
  end

  def optional?
    !required?
  end

  def answered?
    response_set && !response_set.tree_unanswered?(object)
  end

  def visible?
    status == 'active' || (status == 'inactive' && answered?)
  end

  def response_set
    @response_set ||= loan.send(loan_question_set.kind)
  end
end
