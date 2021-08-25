# Wraps Question and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  attr_accessor :selected_division

  def initialize(question, selected_division:, **args)
    super(question)
    self.selected_division = selected_division

    raise ArgumentError.new('Division cannot be nil') unless selected_division

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

    @parent =
      if question.parent.nil?
        nil
      else
        self.class.new(question.parent, selected_division: selected_division, **@args)
      end
  end

  def visible?
    selected_division.self_or_descendant_of?(question.division)
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
    # show visible top level questions in table of contents
    children.select do |m|
      m.top_level? || m.group?
    end
  end

  def question
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
    self.class.decorate_collection(question.children, selected_division: selected_division, **@args)
  end
end
