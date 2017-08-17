# Wraps LoanQuestion and delegates most methods. Also holds a Loan and provides methods relating to the combination
# of the two.
class FilteredQuestion < SimpleDelegator
  attr_accessor :loan

  def initialize(question, loan)
    super(question)
    @loan = loan
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
      parent && parent.required?
    end
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, loan)
  end

  private

  def object
    __getobj__
  end
end
