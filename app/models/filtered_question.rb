# Wraps LoanQuestion and delegates most methods. Also holds a Loan and provides methods relating to the combination
# of the two.
class FilteredQuestion < SimpleDelegator
  attr_accessor :loan

  def self.decorate_collection(collection)
    collection.map { |q| self.class.new(q, loan) }
  end

  def initialize(question, loan)
    super(question)
    @loan = loan
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, loan)
  end

  # Returns child questions that are applicable to the given loan. Sorts by requiredness, then position.
  def children
    @children ||= decorated_children.select(&:visible?).sort_by(&:reqpos)
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

  def answered?
    response_set && !response_set.tree_unanswered?(object)
  end

  private

  def decorated_children
    self.class.decorate_collection(object.children)
  end

  # Returns an array of the form [<required>, <position>] where required is 1 if question is required,
  # 2 if not, and position is the questions position. Used for sorting.
  def reqpos
    @reqpos ||= [required? ? 1 : 2, position]
  end

  def visible?
    status == 'active' || (status == 'inactive' && answered?)
  end

  def response_set
    @response_set ||= loan.send(loan_question_set.kind)
  end

  def object
    __getobj__
  end
end
