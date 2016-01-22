# == Schema Information
#
# Table name: custom_models
#
#  created_at                 :datetime         not null
#  custom_data                :json
#  custom_field_set_id        :integer          not null
#  custom_model_linkable_id   :integer          not null
#  custom_model_linkable_type :string           not null
#  id                         :integer          not null, primary key
#  updated_at                 :datetime         not null
#
# Indexes
#
#  custom_models_on_linkable                   (custom_model_linkable_type,custom_model_linkable_id)
#  index_custom_models_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_99a00e528f  (custom_field_set_id => custom_field_sets.id)
#

#
# Represents a dynamic model instance which can be owned in a one-to-many 'belongs_to' relation by another
# model instance in the system.
# Primary use case are a Loan's Criteria and Loan Post-analysis questionnaires.
# Actual values are stored into a JSON field keyed by the numeric id of the associated field.
# Note, the current design allows for custom field definitions to optionally specificy a 'slug' style field name,
# but does not require it.  The custom value can be resolved either by field id, or the field 'internal_name' if assigned
#

class CustomModel < ActiveRecord::Base
  include CustomValueSettable


  belongs_to :custom_model_linkable, polymorphic: true
  belongs_to :custom_field_set


  # Ducktype interface override of default CustomValueSettable resolve logic.
  # Assumes linkable associated field set assigned when instance was created.
  # Allows leverage of rest of CustomValueSettable implementation
  def resolve_custom_field_set
    custom_field_set
  end


end
