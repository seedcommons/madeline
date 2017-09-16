# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def self.decorate_collection(collection, **args)
    collection.map { |q| self.new(q, **args) }
  end

  def initialize(question, **args)
    super(question)
    @args = args
  end

  def inspect
    "#<#{self.class} object: #{super}>"
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, **@args)
  end

  def children
    @children ||= decorated_children.sort_by(&:position)
  end

  def leaf?
    children.none?
  end

  def child_groups
    children.select(&:group?)
  end

  def object
    __getobj__
  end

  # Should not need this method and it circumvents decoration.
  def self_and_descendants
    raise NotImplementedError
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, **@args)
  end
end
