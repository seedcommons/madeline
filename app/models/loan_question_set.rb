# == Schema Information
#
# Table name: loan_question_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_loan_question_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_a3c049608b  (division_id => divisions.id)
#

class LoanQuestionSet < ActiveRecord::Base
  include Translatable

  belongs_to :division

  has_many :loan_questions, -> { order(:position) }, inverse_of: :loan_question_set

  attr_translatable :label

  def name
    label
  end

  def kind
    internal_name.sub(/^loan_/, '').to_sym
  end

  def children
    loan_questions.where(parent: nil)
  end
  alias_method :kids, :children

  def child_groups
    children.select(&:group?)
  end

  def depth
    -1
  end

  # Builds and memoizes a hash of the form:
  # {
  #   q1 => {
  #     q1_1 => {},
  #     q1_2 => {}
  #     q1_3 => {
  #       q1_1_1 => {},
  #       q1_1_2 => {}
  #     }
  #   },
  #   q2 => {
  #     q2_1 => {},
  #     q2_2 => {}
  #   },
  #   q3 => {},
  #   q4 => {}
  # }
  # i.e. at each level, the tree elements are represented by hash keys and the children of each
  # element are the hash values.
  # Requires only N+1 database queries where N is the number of top level LoanQuestions.
  # Uses the closure_tree method of the same name.
  def hash_tree
    @hash_tree ||= children.map { |c| [c, c.hash_tree[c]] }.to_h
  end

  # Builds and memoizes a hash mapping LoanQuestions to their children for all LoanQuestions in this set.
  # Requires no further database calls beyond those needed for `hash_tree`.
  # Uses the hash to return the children of the given parent.
  def kids_for_parent(parent)
    if @kids_by_parent.nil?
      @kids_by_parent = {}
      build_parent_kid_hash_for(hash_tree)
    end
    @kids_by_parent[parent]
  end

  # Gets a LoanQeustion by its id, internal_name, or the LoanQuestion itself.
  def question(question_identifier, required: true)
    if question_identifier.is_a?(LoanQuestion)
      question = question_identifier
    elsif question_identifier.is_a?(Integer)
      question = loan_questions.find_by(id: question_identifier)
    else
      question = loan_questions.find_by(internal_name: question_identifier)
    end
    raise "LoanQuestion not found: #{question_identifier} for set: #{internal_name}"  if required && !question
    question
  end

  private

  # Recursive method to construct @kids_by_parent.
  def build_parent_kid_hash_for(tree)
    tree.each_pair do |question, subtree|
      # Need to associate this copy of self with each descendant or performance will be poor.
      question.loan_question_set = self
      @kids_by_parent[question] = subtree.keys
      build_parent_kid_hash_for(subtree)
    end
  end
end
