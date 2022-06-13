# Inherits from FilteredQuestion. Adds a Loan and provides methods relating to the combination of the two.


class LoanFilteredQuestion < FilteredQuestion
  include ProgressCalculable

  attr_accessor :loan
  attr_accessor :answer
  attr_accessor :progress_numerator
  attr_accessor :progress_denominator
  attr_accessor :is_leaf

  def initialize(question, **args)
    @loan = args[:loan]
    @response_set = args[:response_set]
    super(question, selected_division: @loan.division, **args)
  end

  def answered?
    is_leaf? && progress_numerator == 1
  end

  def is_leaf?
    question.data_type != :group
  end

  def blank?
    progress_numerator == 0
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

  def visible?
    return @visible if defined?(@visible)
    @visible = super && (active? || answered?)
  end

  def response_set
    @response_set ||= ResponseSet.find_by(loan: loan, question_set: question_set)
  end

  # traverse question tree to add answers & progress information
  # should only be called with root once per page load
  def self.decorate_responses(node, response_set)
    if node.group?
      children = node.children.each{ |c| self.decorate_responses(c, response_set) }
      node.progress_numerator = (self.progress_applicable(children, node).map(&:progress_numerator)).sum
      node.progress_denominator = (self.progress_applicable(children, node).map(&:progress_denominator)).sum
    else
      node.answer = response_set.answers.select{|a| a.question_id == node.id}.first
      node.progress_numerator = node.answer.blank? ? 0 : 1
      node.progress_denominator = 1
    end
    return node
  end

  # Inactive questions should be ignored. Inactive questions only show when they are
  # answered, and they are never required, so progress makes no sense. Retired questions should
  # never show, so they should be excluded as well.
  # If the current response is required, only count children that are also required.
  def self.progress_applicable(lfqs, parent)
    lfqs.select do |q|
      if parent.required?
        q.active? && q.required?
      else
        q.active?
      end
    end
  end
end
