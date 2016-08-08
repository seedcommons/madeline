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
  include CustomFieldAddable


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
    custom_data.values.map { |v| v["url"] }.compact
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
