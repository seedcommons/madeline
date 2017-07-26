# == Schema Information
#
# Table name: loan_questions
#
#  created_at            :datetime         not null
#  data_type             :string
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  loan_question_set_id  :integer
#  migration_position    :integer
#  override_associations :boolean          default(FALSE), not null
#  parent_id             :integer
#  position              :integer
#  required              :boolean          default(FALSE), not null
#  status                :string           default("active"), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_loan_questions_on_loan_question_set_id  (loan_question_set_id)
#
# Foreign Keys
#
#  fk_rails_a32cf017b9  (loan_question_set_id => loan_question_sets.id)
#

# Full conceptual meaning of 'override_associations' boolean:
# "This question specifies its own set of required loan types rather than inheriting from its
# parent question"


class LoanQuestion < ActiveRecord::Base
  include Translatable

  OVERRIDE_ASSOCIATIONS_OPTIONS = %i(false true)

  belongs_to :loan_question_set

  # Used for Questions(LoanQuestion) to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :loan_question_requirements, dependent: :destroy
  accepts_nested_attributes_for :loan_question_requirements, allow_destroy: true

  # has_many :options, through: :loan_question_requirements
  # alias_method :loan_types, :options
  has_many :loan_types, class_name: 'Option', through: :loan_question_requirements

  # note, the custom field form layout can be hierarchially nested
  has_closure_tree order: 'position', dependent: :destroy

  # Bug in closure_tree's built in methods requires this fix
  # https://github.com/mceachen/closure_tree/issues/137
  has_many :self_and_descendants, through: :descendant_hierarchies, source: :descendant
  has_many :self_and_ancestors, through: :ancestor_hierarchies, source: :ancestor

  # Transient value populated by depth first traversal of questions scoped to a specific division.
  # Starts with '1'.  Used in hierarchical display of questions.
  attr_accessor :transient_position

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label
  attr_translatable :explanation

  delegate :division, :division=, to: :loan_question_set

  validates :data_type, presence: true

  after_save :ensure_internal_name
  after_commit :set_number

  DATA_TYPES = %i(string text number range group boolean breakeven business_canvas)

  def children_sorted_by_required(loan)
    children.sort_by { |c| [c.required_for?(loan) ? 0 : 1, c.position] }
  end

  def children_sorted_by_position
    children.sort_by(&:position)
  end

  # Selects only those questions that are applicable to the given loan.
  def children_applicable_to(loan)
    @children_applicable_to ||= {}
    @children_applicable_to[loan] ||= if loan
      children_sorted_by_required(loan).select do |c|
        c.status == 'active' || (c.status == 'inactive' && c.answered_for?(loan))
      end
    else
      children_sorted_by_position.select { |c| c.status != 'retired' }
    end
  end

  def top_level?
    parent.root?
  end

  # Overriding this method because the closure_tree implementation causes a DB query.
  def depth
    @depth ||= root? ? 0 : parent.depth + 1
  end

  def answered_for?(loan)
    response_set = loan.send(loan_question_set.kind)
    return false if !response_set
    !response_set.tree_unanswered?(self)
  end

  # Resolves if this particular question is considered required for the provided loan, based on
  # presence of association records in the loan_questions_options relation table, and the
  # 'override_associations' flag.
  # - If override is true and join records are present, question is required for those loan types
  #   and optional for all others
  # - If override is true and no records are present, all are optional
  # - If override is false, inherit from parent
  # - Top level nodes (those with depth = 1 are direct children of the root) effectively have
  #   override always true
  # Note, loan type association records are ignored for questions without the 'override_assocations'
  # flag assigned.
  def required_for?(loan)
    if override_associations || depth == 1
      loan_types.include?(loan.loan_type_option)
    else
      parent && parent.required_for?(loan)
    end
  end

  def name
    "#{loan_question_set.internal_name}-#{internal_name}"
  end

  def attribute_sym
    internal_name.to_sym
  end

  def group?
    data_type == 'group'
  end

  def active?
    status == 'active'
  end

  def child_groups
    children_sorted_by_position.select(&:group?)
  end

  def first_child?
    @first_child ||= parent && parent.children.none? { |q| q.position < position }
  end

  # List of value keys for fields which have nested values
  def value_types
    # raise "invalid data_type" unless DATA_TYPES.include?(data_type.to_sym)
    if data_type == 'range'
      result = [:rating, :text]
    else
      result = [data_type.to_sym]
    end

    if has_embeddable_media
      if result
        result << :url
      else
        raise "has_embeddable_media flag enabled for unexpected data_type: #{data_type}"
      end
    end
    result
  end

  # for now use a stringified primary key
  # todo: consider using the internal name when available - needs further discussion
  def json_key
    id.to_s
  end

  # For table of loan types on loan question edit. Returns a complete set of requirement
  # objects, one for each loan type, whether it already exists or not.
  def build_complete_requirements
    (Loan.loan_type_option_set.options - loan_question_requirements.map(&:loan_type)).each do |lt|
      loan_question_requirements.build(loan_type: lt)
    end
  end

  protected

  def set_number
    puts 'got here - callback'
    update_column(:number, siblings_before.where(status: 'active').count + 1)
  end

  private

    def ensure_internal_name
      if !internal_name
        self.update! internal_name: "field_#{id}"
      end
    end
end
