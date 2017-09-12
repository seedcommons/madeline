# Inherits from LoanQuestion. Adds a Loan and provides methods relating to the combination of the two.
class LoanFilteredQuestion < FilteredQuestion
  attr_accessor :loan

  # the super initialize is breaking this in the tests since it requires a division
  # I'm thinking two things. At the moment, preferring 1
    # create a separate class that inherits from filtered_questions for division
    # update this initialize method, the tests for it and all other usages with division arg
  def initialize(question, loan)
    super(question)
    @loan = loan
  end

  def parent
    super(loan)
  end

  # Returns child questions that are applicable to the given loan. Sorts by requiredness, then position.
  def children
    @children ||= super(sort: [required? ? 1 : 2, position]).select(&:visible?)
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
    if override_associations || depth == 1
      loan_types.include?(loan.loan_type_option)
    else
      parent&.required?
    end
  end

  def answered?
    response_set && !response_set.tree_unanswered?(object)
  end

  private

  def visible?
    status == 'active' || (status == 'inactive' && answered?)
  end

  def response_set
    @response_set ||= loan.send(loan_question_set.kind)
  end
end
