# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def initialize(question, division: nil, **args)
    super(question)
    @division = division
    @args = args
  end

  def self.decorate_collection(collection, **args)
    collection.map { |q| self.new(q, **args) }
  end

  def inspect
    "#<#{self.class} object: #{super}>"
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, **@args)
  end

  def visible?
    (object.division == @division) || object.division.ancestors.include?(@division)
  end

  def children
    @children ||= decorated_children.sort_by(&:position)
  end

  # Returns the decorated question
  def object
    __getobj__
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, **@args)
  end
end
