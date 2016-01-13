# == Schema Information
#
# Table name: custom_fields
#
#  id                  :integer          not null, primary key
#  custom_field_set_id :integer
#  internal_name       :string
#  label               :string
#  data_type           :string
#  position            :integer
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_custom_fields_on_custom_field_set_id  (custom_field_set_id)
#

class CustomField < ActiveRecord::Base
  include Translatable

  belongs_to :custom_field_set
  # note, the custom field form layout can be hierarchially nested
  belongs_to :parent, class_name: 'CustomField'


  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label



  def name
    "#{custom_field_set.internal_name}-#{internal_name}"
  end


  DATA_TYPES = ['string', 'text', 'number', 'range', 'group']


end
