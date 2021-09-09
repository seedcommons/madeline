# Inherits from FilteredQuestion. Adds a Loan and provides methods relating to the combination of the two.
class LoanFilteredQuestion < FilteredQuestion
  attr_accessor :loan

  def initialize(question, **args)
    @loan = args[:loan]
    super(question, selected_division: @loan.division, **args)
  end

  def sort_key
    [required? ? 1 : 2, position]
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
    return @required if defined?(@required)
    @required = if override_associations || depth == 1
      loan_types.include?(loan.loan_type_option)
    else
      root? ? true : parent.required?
    end
  end

  def optional?
    !required?
  end

  def answered?
    return @answered if defined?(@answered)
    @answered = response_set && response_set.response(self).present?
  end

  def progress_pct
    return @progress_pct if defined?(@progress_pct)
    @progress_pct = self.response_set.response(self).progress_pct
  end

  def visible?
    return @visible if defined?(@visible)
    @visible = super && (active? || answered?)
  end

  def response_set
    @response_set ||= ResponseSet.find_by(loan: loan, question_set: question_set)
  end
end
