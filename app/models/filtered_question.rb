# Wraps LoanQuestion and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  def initialize(question, division:)
    @question = question
    @division = division
  end

  def self.decorate_collection(collection)
    collection.map { |q| self.class.new(q, loan) }
  end

  def parent(*args)
    return @parent if defined?(@parent)
    @parent = object.parent.nil? ? nil : self.class.new(object.parent, *args)
  end

  def children(sort: :position)
    @children ||= decorated_children.sort_by(&sort)
  end

  def visible?
    @question.division == @division || @question.division.ancestors.include?(@division)
  end

  private

  def decorated_children
    self.class.decorate_collection(object.children)
  end

  def object
    __getobj__
  end
end
