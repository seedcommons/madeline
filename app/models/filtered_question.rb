# Wraps Question and delegates most methods, but enables filtering by loan and division via subclasses.
class FilteredQuestion < SimpleDelegator
  attr_accessor :selected_division

  # include_descendant_divisions means we want to show a question if it belongs to a division that
  # is a descendant of selected_division. We ALWAYS include questions that are from divisions that are
  # ancestors of the selected_division.
  def initialize(question, selected_division:, include_descendant_divisions: false, **args)
    super(question)
    self.selected_division = selected_division
    self.include_descendant_divisions = include_descendant_divisions

    raise ArgumentError.new("Division cannot be nil") unless selected_division

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
        self.class.new(question.parent, selected_division: selected_division,
                                        include_descendant_divisions: include_descendant_divisions,
                                        **@args)
      end
  end


  def visible?
    selected_division.self_or_descendant_of?(question.division) ||
      include_descendant_divisions && selected_division.self_or_ancestor_of?(question.division)
  end

  # NOTE: treats a question group with no active children as a leaf
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
    self.class.decorate_collection(question.children,
                                   selected_division: selected_division,
                                   include_descendant_divisions: include_descendant_divisions,
                                   **@args)
  end

  private

  attr_accessor :include_descendant_divisions
end
