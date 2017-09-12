# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def self.decorate_collection(collection, **args)
    collection.map { |q| self.new(q, **args) }
  end

  def initialize(question, **args)
    super(question)
    @args = args
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, **@args)
  end

  def children
    @children ||= decorated_children.sort_by(&:position)
  end

  def object
    __getobj__
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, **@args)
  end
end
