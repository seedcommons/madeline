# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def initialize(question, division:, **args)
    @question = question
    @division = division
    @args = args
  end

  def self.decorate_collection(collection, args)
    collection.map { |q| self.new(q, **args) }
  end

  def parent
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, **@args)
  end

  def visible?
    (@question.division == @division) || @question.division.ancestors.include?(@division)
  end

  private
  def children
    @children ||= decorated_children.sort_by(&:position)
  end

  def object
    __getobj__
  end

  protected

  def decorated_children
    self.class.decorate_collection(object.children, @args)
  end
end
