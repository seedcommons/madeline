# Inherits from FilteredQuestion. Adds a Loan and provides methods relating to the combination of the two.


class LoanFilteredQuestion < FilteredQuestion
  include ProgressCalculable

  attr_accessor :loan
  attr_accessor :answer
  attr_accessor :progress_numerator
  attr_accessor :progress_denominator
  attr_accessor :is_leaf

  def initialize(question, loan: nil, response_set: nil, parent: nil)
    @parent = parent
    @loan = loan
    @response_set = response_set
    @children = []
    super(question, selected_division: @loan.division)
    if question.group?
      @children = question.children.map do |q|
        LoanFilteredQuestion.new(q, loan: loan, response_set: response_set, parent: self)
      end
    else
      self.answer = response_set.answers.find{ |a| a.question_id == question.id } if response_set
    end
    #add_leaf_and_progress_info
  end

  # INSTANCE METHODS

  def add_leaf_and_progress_info
    # for now, ask if question has children bc question model doesn't override children
    if question.group?
      # traverse depth first because need to know children info to figure out parent info
      @children.each{ |c| c.add_leaf_and_progress_info }
      # since answers have been added we have enough info to determine if a child is visible
      is_leaf = @children.empty? # TODO UPDATE to exclude non active children
      puts @children
      progress_numerator = @children.map(&:progress_numerator).sum
      progress_denominator = @children.map(&:progress_denominator).sum
    else
      progress_numerator = answered? ? 1 : 0 #stick with this for now & see if this even runs . . .
      progress_denominator = 1
      is_leaf = true # TODO can be leaf if no visible children
    end
  end



  def not_applicable?
    answer.present? && answer.not_applicable?
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
      parent_lfq = parent
      root? ? true : parent_lfq.required?
    end
  end

  def parent
    puts "in parent method"
    return @parent if @parent.present?
    @parent =
      if question.parent.nil?

        nil
      else
        self.class.new(question.parent, loan: @loan, response_set: @response_set)
      end
  end

  def children
    @children
  end

  def decorated_children
    @decorated_children ||
      self.class.decorate_collection(question.children, @loan, @response_set)
  end

  def optional?
    !required?
  end

  def visible?
    return @visible if defined?(@visible)
    #super checks if loan division is self or desc of question's division
    @visible = super && (active? || answered?)
  end

  def response_set
    @response_set ||= ResponseSet.find_by(loan: loan, question_set: question_set)
  end
end
