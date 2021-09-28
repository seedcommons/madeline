class QuestionSet < ApplicationRecord
  include Translatable

  KINDS = %i[loan_criteria loan_post_analysis].freeze

  belongs_to :division, inverse_of: :question_sets
  has_many :response_sets, inverse_of: :question_set, dependent: :restrict_with_exception

  has_closure_tree_root :root_group, class_name: "Question"

  after_create :create_root_group!

  def self.find_for_division(division)
    self_and_ancestor_ids = division.self_and_ancestors.pluck(:id)
    KINDS.map do |kind|
      candidates = where(kind: kind, division_id: self_and_ancestor_ids).index_by(&:division_id)
      self_and_ancestor_ids.lazy.map { |div_id| candidates[div_id] }.detect { |set| !set.nil? }
    end.compact
  end

  def root_group_preloaded
    @root_group_preloaded ||=
      root_group_including_tree(loan_types: :translations, loan_question_requirements: :loan_type)
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

    raise "Question not found: #{question_identifier} for set: #{kind}" if required && !result
    result
  end

  def summary_questions?
    questions.where(display_in_summary: true).count > 0
  end

  private

  # This is private because it is needed to allow the inverse association on Question, but
  # it should never be used directly. Access children via the root or by cache hashes.
  has_many :questions, inverse_of: :question_set, dependent: :destroy

  def create_root_group!
    Question.create!(
      question_set_id: id,
      parent: nil,
      data_type: "group",
      internal_name: "root_#{id}",
      division: Division.root
    )
  end

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
