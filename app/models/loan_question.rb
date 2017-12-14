# == Schema Information
#
# Table name: loan_questions
#
#  created_at            :datetime         not null
#  data_type             :string
#  division_id           :integer          not null
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  loan_question_set_id  :integer
#  migration_position    :integer
#  number                :integer
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
  DATA_TYPES = %i(string text number range group boolean breakeven business_canvas)

  # These methods are troublesome because they circumvent eager loading and also cause leaks in
  # decoration. We can do without them! Better to use children and parent to walk the tree and get
  # what you need. We are not dealing with huge trees!
  BANNED_METHODS = %i(root leaves child_ids ancestors ancestor_ids self_and_ancestors_ids
    siblings sibling_ids self_and_siblings descendants descendant_ids
    self_and_descendant_ids hash_tree find_by_path find_or_create_by_path find_all_by_generation)

  belongs_to :loan_question_set
  belongs_to :division

  # Used for Questions(LoanQuestion) to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :loan_question_requirements, dependent: :destroy
  accepts_nested_attributes_for :loan_question_requirements, allow_destroy: true

  # has_many :options, through: :loan_question_requirements
  # alias_method :loan_types, :options
  has_many :loan_types, class_name: 'Option', through: :loan_question_requirements

  # note, the custom field form layout can be hierarchically nested
  has_closure_tree order: 'position', dependent: :destroy

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label
  attr_translatable :explanation

  validates :data_type, presence: true

  after_save :ensure_internal_name

  before_save :prepare_numbers
  after_commit :set_numbers

  def top_level?
    parent.root?
  end

  # Overriding this method because the closure_tree implementation causes a DB query.
  def depth
    @depth ||= root? ? 0 : parent.depth + 1
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

  def top_level_group?
    group? && top_level?
  end

  def business_canvas?
    data_type == 'business_canvas'
  end

  def active?
    status == 'active'
  end

  def first_child?
    @first_child ||= parent && parent.children.none? { |q| q.position < position }
  end

  def decorated?
    false
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

  def full_number
    return @full_number if defined?(@full_number)
    @full_number = if number.nil? || parent.nil?
      nil
    elsif parent.root?
      number.to_s
    elsif parent.full_number
      "#{parent.full_number}.#{number}"
    end
  end

  def full_number_and_label
    [full_number, label].compact.join(" ")
  end

  # See comment above on constant definition.
  BANNED_METHODS.each do |m|
    define_method(m) do |*args|
      raise NotImplementedError(m.to_s)
    end
  end

  protected

  def set_numbers
    update_numbers_for_parent(parent_id) if parent_id
    update_numbers_for_parent(@old_parent_id) if @old_parent_id
  end

  def update_numbers_for_parent(parent_id)
    self.class.connection.execute("UPDATE loan_questions SET number = num FROM (
      SELECT id, ROW_NUMBER() OVER (ORDER BY POSITION) AS num
      FROM loan_questions
      WHERE parent_id = #{parent_id} AND status = 'active'
    ) AS t WHERE loan_questions.id = t.id")
  end

  private

  def prepare_numbers
    self.number = nil if status_changed? && status != 'active'
    @old_parent_id = parent_id_changed? ? parent_id_was : nil
    true
  end

  def ensure_internal_name
    if !internal_name
      self.update! internal_name: "field_#{id}"
    end
  end
end
