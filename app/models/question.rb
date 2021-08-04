# Full conceptual meaning of 'override_associations' boolean:
# "This question specifies its own set of required loan types rather than inheriting from its
# parent question"


class Question < ApplicationRecord
  include Translatable
  using Romanize
  using Letterize

  OVERRIDE_ASSOCIATIONS_OPTIONS = %i(false true)
  DATA_TYPES = %i(boolean breakeven business_canvas currency group number percentage range text)

  # These methods are troublesome because they circumvent eager loading and also cause leaks in
  # decoration. We can do without them! Better to use children and parent to walk the tree and get
  # what you need. We are not dealing with huge trees!
  BANNED_METHODS = %i(root leaves child_ids ancestors ancestor_ids self_and_ancestors_ids
    siblings sibling_ids self_and_siblings descendants descendant_ids
    self_and_descendant_ids hash_tree find_by_path find_or_create_by_path find_all_by_generation)

  belongs_to :question_set
  belongs_to :division

  # Used for Questions to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :loan_question_requirements, dependent: :destroy
  accepts_nested_attributes_for :loan_question_requirements, allow_destroy: true

  # has_many :options, through: :loan_question_requirements
  # alias_method :loan_types, :options
  has_many :loan_types, class_name: 'Option', through: :loan_question_requirements

  # note, the custom field form layout can be hierarchically nested
  has_closure_tree order: 'position', numeric_order: true, dependent: :destroy

  # define accessor like convenience methods for the fields stored in the Translations table
  translates :label
  translates :explanation, allow_html: true

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
    "#{question_set.internal_name}-#{internal_name}"
  end

  def attribute_sym
    internal_name.to_sym
  end

  def group?
    data_type == 'group'
  end

  def summary_group?
    return false unless group?
    return false if children.none?
    return true if children.any?(&:display_in_summary)
    children.any?(&:summary_group?)
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
    elsif data_type == 'percentage'
      result = [:number, :percentage]
    elsif data_type == 'currency'
      result = [:number, :currency]
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

  # For table of loan types on question edit. Returns a complete set of requirement
  # objects, one for each loan type, whether it already exists or not.
  def build_complete_requirements
    (Loan.loan_type_option_set.options - loan_question_requirements.map(&:loan_type)).each do |lt|
      loan_question_requirements.build(loan_type: lt)
    end
  end

  # name kept due to compatibility issues
  # TODO: remove during question refactor
  def full_number
    @full_number ||= outline_number
  end

  def outline_number
    return unless number
    case (self.depth - 1) % 6
    when 0
      number.romanize
    when 1
      number.letterize
    when 2
      number.to_s
    when 3
      number.letterize.downcase
    when 4
      number.romanize.downcase
    when 5
      "(" + number.letterize.downcase + ")"
    end
  end

  def full_number_and_label
    [full_number, label].compact.join(". ")
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
    self.class.connection.execute("UPDATE questions SET number = num FROM (
      SELECT id, ROW_NUMBER() OVER (ORDER BY POSITION) AS num
      FROM questions
      WHERE parent_id = #{parent_id} AND status = 'active'
    ) AS t WHERE questions.id = t.id")
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
