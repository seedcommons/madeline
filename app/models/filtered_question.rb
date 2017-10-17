# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def initialize(question, **args)
    super(question)
    @user = args[:user]
    @division = args[:division]

    raise ArgumentError.new('User can not be nil') unless @user
    raise ArgumentError.new('Division can not be nil') unless @division

    # We save these so we can reuse them when decorating children and parents.
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
    allowed? && object.division.self_and_descendants.include?(@division)
  end

  def children
    @children ||= decorated_children.select(&:visible?).sort_by(&:sort_key)
  end

  def sort_key
    position
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

  def decorated?
    true
  end

  # Should not need this method and it circumvents decoration.
  def self_and_descendants
    raise NotImplementedError
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, **@args)
  end

  def allowed?
    @user == :system || LoanQuestionPolicy.new(@user, object).show?
  end
end
