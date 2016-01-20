# == Schema Information
#
# Table name: custom_field_sets
#
#  created_at    :datetime         not null
#  division_id   :integer
#  id            :integer          not null, primary key
#  internal_name :string
#  label         :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_field_sets_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_a3c049608b  (division_id => divisions.id)
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
