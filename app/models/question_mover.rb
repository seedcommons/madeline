# Moves questions within the global question tree.
# Checks to make sure the move is valid before executing it.
class QuestionMover
  include ActiveModel::Model

  attr_accessor :current_division, :question, :target, :relation

  def move
    raise ArgumentError, "invalid relation" unless %i[before after inside].include?(relation)

    ensure_current_division
    ensure_new_parent_is_group
    ensure_correct_adjacency
    ensure_parent_of_same_or_ancestor_division
    method =
      case relation
      when :before then :prepend_sibling
      when :after then :append_sibling
      when :inside then :prepend_child
      end
    target.send(method, question)
  end

  private

  def new_parent
    @new_parent ||=
      case relation
      when :inside then target
      else target.parent
      end
  end

  def siblings
    @siblings ||= new_parent.children.includes(:division).to_a
  end

  def siblings_in_same_division?
    siblings.any? { |s| s.division_id == question.division_id }
  end

  def ensure_current_division
    raise ArgumentError, "must be in current division" unless question.division_id == current_division.id
  end

  def ensure_new_parent_is_group
    raise ArgumentError, "parent must be group" unless new_parent.group?
  end

  def ensure_correct_adjacency
    target_index = siblings.index(target)
    sib_count = siblings.size
    pos = case relation
          when :inside then 0
          when :before then target_index
          else target_index + 1
          end

    if siblings_in_same_division?
      return if (pos > 0 && siblings[pos - 1].division_id == question.division_id) ||
        (pos < sib_count && siblings[pos].division_id == question.division_id)

      raise ArgumentError, "must be adjacent to questions of same division"
    else
      return if (pos == 0 || siblings[pos - 1].division_depth <= question.division_depth) &&
        (pos >= sib_count || siblings[pos].division_depth >= question.division_depth)

      raise ArgumentError, "must be adjacent to questions of same division depth"
    end
  end

  def ensure_parent_of_same_or_ancestor_division # i.e. same or lower division depth
    our_division = question.division
    parent_division = new_parent.division
    return if our_division.depth >= parent_division.depth

    raise ArgumentError, "must have parent of same or ancestor division"
  end
end
