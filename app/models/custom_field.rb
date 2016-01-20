# == Schema Information
#
# Table name: custom_fields
#
#  created_at          :datetime         not null
#  custom_field_set_id :integer
#  data_type           :string
#  id                  :integer          not null, primary key
#  internal_name       :string
#  label               :string
#  parent_id           :integer
#  position            :integer
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_custom_fields_on_custom_field_set_id  (custom_field_set_id)
#
# Foreign Keys
#
#  fk_rails_b30226ad05  (custom_field_set_id => custom_field_sets.id)
#

class CustomField < ActiveRecord::Base
  include Translatable

  belongs_to :custom_field_set
  # note, the custom field form layout can be hierarchially nested

  has_closure_tree
  belongs_to :parent, class_name: 'CustomField'


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label



  def name
    "#{custom_field_set.internal_name}-#{internal_name}"
  end


  DATA_TYPES = ['string', 'text', 'number', 'range', 'group']


end
