# == Schema Information
#
# Table name: custom_fields
#
#  created_at            :datetime         not null
#  custom_field_set_id   :integer
#  data_type             :string
#  has_embeddable_media  :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  internal_name         :string
#  migration_position    :integer
#  override_associations :boolean          default(FALSE), not null
#  parent_id             :integer
#  position              :integer
#  required              :boolean          default(FALSE), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_custom_fields_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_b30226ad05  (custom_field_set_id => custom_field_sets.id)
#

# Full conceptual meaning of 'override_associations' boolean:
# "This question specifies its own set of required loan types rather than inheriting from its
# parent question"


class CustomField < ActiveRecord::Base
  include Translatable

  belongs_to :custom_field_set, inverse_of: :custom_fields

  # Used for Questions(CustomField) to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :custom_field_requirements, dependent: :destroy

  # has_many :options, through: :custom_field_requirements
  # alias_method :loan_types, :options
  has_many :loan_types, class_name: 'Option', through: :custom_field_requirements

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

  delegate :division, :division=, to: :custom_field_set

  validates :data_type, presence: true

  after_save :ensure_internal_name

  DATA_TYPES = %i(string text number range group boolean breakeven)

  def self.loan_questions(field_set = nil)
    # field_set is a string, either 'criteria' or 'post_analysis', or nil. If it's given, it needs
    # to be prepended for the database, and if it's not, it is set to both, to return all loan questions.
    field_set &&= "loan_#{field_set}"
    field_set ||= ['loan_criteria', 'loan_post_analysis']
    joins(:custom_field_set).where(custom_field_sets:
      { internal_name: field_set })
  end

  # Note: Not chainable; intended to be called on a subset
  def self.sort_by_required(loan)
    all.sort_by { |i| [i.required_for?(loan) ? 0 : 1, i.position] }
  end

  # Feature #4737
  # Resolves if this particular question is considered required for the provided loan, based on
  # presence of association records in the custom_fields_options relation table, and the
  # 'override_associations' flag.
  # - If override is true and join records are present, question is required for those loan types
  #   and optional for all others
  # - If override is true and no records are present, all are optional
  # - If override is false, inherit from parent
  # - Root nodes effectively have override always true
  # Note, loan type association records are ignored for questions without the 'override_assocations'
  # flag assigned.
  def required_for?(loan)
    if override_associations || root?
      loan_types.include?(loan.loan_type_option)
    else
      parent && parent.required_for?(loan)
    end
  end

  def name
    "#{custom_field_set.internal_name}-#{internal_name}"
  end

  def attribute_sym
    internal_name.to_sym
  end

  # Alternative to children method from closure_tree that uses the kids_for_parent method of
  # the associated CustomFieldSet, which loads the entire tree in a small number of DB queries.
  # Returns [] if this CustomField has no children.
  def kids
    custom_field_set.kids_for_parent(self)
  end

  def group?
    data_type == 'group'
  end

  def child_groups
    children.select(&:group?)
  end

  def first_child?
    parent && siblings_before.empty?
  end

  # List of value keys for fields which have nested values
  def value_types
    result =
      case data_type
      when 'string' then [:text]
      when 'text' then [:text]
      when 'number' then [:number]
      when 'range' then [:rating, :text]
      when 'boolean' then [:boolean]
      when 'breakeven' then [:breakeven]
      else []
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

  # TODO: Not used anywhere? Remove?
  # Simple form type mapping
  def form_field_type
    case data_type
    when 'string'
      :string
    when 'text'
      :text
    when 'number'
      :decimal
    when 'range'
      :select
    when 'boolean'
      :boolean
    when 'group'
      nil # group type fields are not expected to have rendered form fields
    end
  end

  def traverse_depth_first(list)
    list << self
    counter = 0
    children.each do |child|
      counter += 1
      child.transient_position = counter
      child.traverse_depth_first(list)
    end
  end

  # for now use a stringified primary key
  # todo: consider using the internal name when available - needs further discussion
  def json_key
    id.to_s
  end

  # We are deprecating this field type, due to lack of need and much added complexity,
  # but this method is still used heavily in custom_field_addable.rb, so leaving this
  # here for now on the off chance that we end up needing this field type after all.
  def translatable?
    false
  end

  private

    def ensure_internal_name
      if !internal_name
        self.update! internal_name: "field_#{id}"
      end
    end
end
