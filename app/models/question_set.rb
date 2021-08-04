class QuestionSet < ApplicationRecord
  include Translatable

  has_closure_tree_root :root_group, class_name: "Question"

  translates :label

  after_create :create_root_group!

  # This is a temporary method that creates root groups for all question sets in the system.
  # It is called from a Rails migration and from the old system migration.
  # It should be removed once all the data are migrated and stable.
  def self.create_root_groups!
    QuestionSet.all.each do |set|
      roots = Question.where(question_set_id: set.id, parent: nil).to_a
      new_root = roots.detect { |r| r.internal_name =~ /\Aroot_/ } || set.create_root_group!
      (roots - [new_root]).each { |r| r.update!(parent: new_root) }
    end
  end

  def create_root_group!
    raise "Must be persisted" unless persisted?
    Question.create!(
      question_set_id: id,
      parent: nil,
      data_type: "group",
      internal_name: "root_#{id}",
      required: true,
      position: 0,
      division: Division.root
    )
  end

  def root_group_preloaded
    @root_group_preloaded ||=
      root_group_including_tree(loan_types: :translations, loan_question_requirements: :loan_type)
  end

  def name
    label
  end

  def kind
    internal_name.sub(/^loan_/, '').to_sym
  end

  def depth
    -1
  end

  # Gets a Question by its id, internal_name, or the Question itself.
  # Uses the node_lookup_table so that it does not trigger any new database queries once the table is built.
  def question(question_identifier, required: true)
    # Return immediately if we are passed a Question or FilteredQuestion.
    if question_identifier.is_a?(Question) || question_identifier.is_a?(FilteredQuestion)
      return question_identifier
    end

    build_node_lookup_table_for(root_group_preloaded) unless @node_lookup_table

    result = if question_identifier == :root
      root_group_preloaded
    else
      @node_lookup_table[question_identifier]
    end

    raise "Question not found: #{question_identifier} for set: #{internal_name}" if required && !result
    result
  end

  def summary_questions?
    questions.where(display_in_summary: true).count > 0
  end

  private

  # This is private because it is needed to allow the inverse association on Question, but
  # it should never be used directly. Access children via the root or by cache hashes.
  has_many :questions, inverse_of: :question_set

  # Recursive method to construct @node_lookup_table, which is a hash of
  # node IDs and internal_names to the nodes themselves.
  # If the `node` argument was retrieved using root_group_including_tree, then this method
  # should not trigger any additional queries.
  def build_node_lookup_table_for(node)
    @node_lookup_table ||= {}
    @node_lookup_table[node.id] = node
    @node_lookup_table[node.internal_name] = node if node.internal_name.present?

    node.children.includes(:children).each { |child| build_node_lookup_table_for(child) }
  end
end
