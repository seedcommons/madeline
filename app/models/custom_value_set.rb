# == Schema Information
#
# Table name: custom_value_sets
#
#  created_at                     :datetime         not null
#  custom_data                    :json
#  custom_field_set_id            :integer          not null
#  custom_value_set_linkable_id   :integer          not null
#  custom_value_set_linkable_type :string           not null
#  id                             :integer          not null, primary key
#  linkable_attribute             :string
#  updated_at                     :datetime         not null
#
# Indexes
#
#  custom_value_sets_on_linkable                   (custom_value_set_linkable_type,custom_value_set_linkable_id)
#  index_custom_value_sets_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_ea4b017c24  (custom_field_set_id => custom_field_sets.id)
#

#
# Represents a dynamic model instance which can be owned in a one-to-many 'belongs_to' relation by another
# model instance in the system.
# Primary use case are a Loan's Criteria and Loan Post-analysis questionnaire 'response sets'.
# This model is only needed for one-to-many relations from an owning object to a related but distinct instance
# Actual values are stored into a JSON field keyed by the numeric id of the associated field.
# Note, the current design allows for custom field definitions to optionally specificy a 'slug' style field name,
# but does not require it.  The custom value can be resolved either by field id, or the field 'internal_name' if assigned
#

class CustomValueSet < ActiveRecord::Base
  include CustomFieldAddable, ProgressCalculable


  belongs_to :custom_value_set_linkable, polymorphic: true
  belongs_to :custom_field_set

  validates :custom_value_set_linkable, presence: true
  validate :custom_fields_valid

  delegate :division, :division=, to: :custom_value_set_linkable

  # Ducktype interface override of default CustomValueSettable resolve logic.
  # Assumes linkable associated field set assigned when instance was created.
  # Allows leverage of rest of CustomValueSettable implementation
  def resolve_custom_field_set(required: true)
    custom_field_set
  end

  # used by raw crud admin views
  def name
    "#{custom_value_set_linkable.name} - #{linkable_attribute}"
  end

  # Fetches urls of all embeddable media in the whole custom value set
  def embedded_urls
    return [] if custom_data.blank?
    emb_ids = custom_data.values.map { |v| v["embeddable_media_id"] }.compact
    EmbeddableMedia.find(emb_ids).map(&:url)
  end

  # Gets LoanResponses whose CustomFields are children of the CustomField of the given LoanResponse.
  # CustomValueSet knows about response data, while CustomField knows about field hierarchy, so placing
  # this responsibility in CustomValueSet seemed reasonable.
  # Uses the `kids` method in CustomField that reduces number of database calls.
  # Returns [] if no children found.
  def children_of(response)
    parent = response.custom_field
    parent.kids.map { |f| custom_value(f) }
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A CustomValueSet is never required to be fully answered. Requiredness is determined by children.
  def required?
    false
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A CustomValueSet behaves as a group.
  def group?
    true
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # A CustomValueSet behaves as a group so can never be answered.
  def answered?
    false
  end

  # Needed to satisfy the ProgressCalculable duck type.
  # Returns the LoanResponses for the top level questions in the set.
  def children
    top_level_fields = custom_field_set.children
    top_level_fields.map { |f| custom_value(f) }
  end

  private

  def custom_fields_valid
    custom_field_set.depth_first_fields.each do |field|
      loan_response = custom_value(field.id)
      # Note, this is a reference for how server-side validation can be done, but the simple form
      # 'decimal' field type seems to prevent invalid numbers from even being submitted.
      if loan_response.has_number?
        unless is_number_or_blank?(loan_response.number)
          number_sym = "#{field.attribute_sym}__number".to_sym
          errors.add(number_sym, "invalid number")
        end
      end
    end
  end

  def is_number?(object)
    true if Float(object) rescue false
  end

  def is_number_or_blank?(object)
    true if object.blank? || Float(object) rescue false
  end
end
