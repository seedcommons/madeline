# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def initialize(question, division: nil, **args)
    super(question)
    @division = division
    @args = args
  end

  def self.decorate_collection(collection, division: nil, **args)
    collection.map { |q| self.new(q, division: division, **args) }
  end

  def inspect
    "#<#{self.class} object: #{super}>"
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, division: @division, **@args)
  end

  def visible?
    return true if @division.nil?

    @division.loan_questions.include?(object) || object.division.descendants.include?(@division)
  end

  def children
    @children ||= decorated_children.select(&:visible?).sort_by(&:sort_key)
  end

  def sort_key
    position
  end

  # Returns the decorated question
  def object
    __getobj__
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, division: @division, **@args)
  end
end
