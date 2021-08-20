# Moves questions within the global question tree.
# Checks to make sure the move is valid before executing it.
class QuestionMover
  include ActiveModel::Model

  attr_accessor :current_division, :question, :target, :relation

  def move
    raise ArgumentError, "invalid relation" unless %i[before after inside].include?(relation)

    ensure_current_division
    ensure_new_parent_is_group
    ensure_after_questions_of_ancestor_divisions
    ensure_adjacent_to_questions_of_same_division
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

  def ensure_current_division
    raise ArgumentError, "must be in current division" unless question.division_id == current_division.id
  end

  def ensure_new_parent_is_group
    raise ArgumentError, "parent must be group" unless new_parent.group?
  end

  # Ensures there are no questions under new parent after new position with ancestor division
  def ensure_after_questions_of_ancestor_divisions
    siblings = new_parent.children.includes(:division)
    subsequent_questions =
      # :inside means it goes to first spot, so all siblings are subsequent
      if relation == :inside
        siblings
      else
        # Partition children into [[questions before target], [questions after target]]
        new_parent.children.includes(:division).to_a.split(target).last
      end

    # Include target in questions to search if relation is :before
    subsequent_questions.unshift(target) if relation == :before

    # Search subsequent questions for any with ancestor (lower tree depth) division
    invalid = subsequent_questions.any? do |subsequent_question|
      our_division = question.division
      their_division = subsequent_question.division
      their_division.depth < our_division.depth
    end
    raise ArgumentError, "must be after questions of ancestor divisions" if invalid
  end

  def ensure_adjacent_to_questions_of_same_division
    siblings = new_parent.children.to_a

    # If no siblings in same division, this invariant must be satisfied.
    return if siblings.none? { |s| s.division_id == question.division_id }

    valid =
      # If inserting inside, it goes to beginning, so ensure first sibling has same division.
      if relation == :inside
        siblings.first.division_id == question.division_id
      # Else, it means we're inserting adjacent to target, so if target has same division, we're good.
      elsif target.division_id == question.division_id
        true
      # Else we have to check prior or subsequent neighbor, depending on relation.
      else
        # Partition siblings into [[questions before target], [questions after target]]
        prior, subsequent = siblings.split(target)
        if relation == :before
          prior.any? && prior.last.division_id == question.division_id
        else
          subsequent.any? && subsequent.first.division_id == question.division_id
        end
      end
    raise ArgumentError, "must be adjacent to questions of same division" unless valid
  end

  def ensure_parent_of_same_or_ancestor_division # i.e. same or lower division depth
    our_division = question.division
    parent_division = new_parent.division
    return if our_division.depth >= parent_division.depth

    raise ArgumentError, "must have parent of same or ancestor division"
  end
end
