# == Schema Information
#
# Table name: custom_field_sets
#
#  id            :integer          not null, primary key
#  division_id   :integer
#  internal_name :string
#  label         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#

class CustomFieldSet < ActiveRecord::Base
  include Translatable

  belongs_to :division

  has_many :custom_fields, -> { order(:position) }

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label


  def name
    label
  end

end
