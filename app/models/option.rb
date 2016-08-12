# == Schema Information
#
# Table name: options
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  migration_id  :integer
#  option_set_id :integer
#  position      :integer
#  updated_at    :datetime         not null
#  value         :string
#
# Indexes
#
#  index_options_on_option_set_id  (option_set_id)
#
# Foreign Keys
#
#  fk_rails_db3e5d5ea9  (option_set_id => option_sets.id)
#

class Option < ActiveRecord::Base
  include Translatable

  belongs_to :option_set

  # Used for Questions(CustomField) to LoanTypes(Options) associations which imply a required
  # question for a given loan type.
  has_many :custom_field_requirements, dependent: :destroy
  has_many :custom_fields, through: :custom_field_requirements

  delegate :division, :division=, to: :option_set

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label

  # As of 5/26/16, 'description' fields were added to the legacy system mysql database for loan types,
  # but this data has not yet been added to the StaticData population of loan types Options
  #attr_translatable :description

  after_create :ensure_value_assigned

  def ensure_value_assigned
    unless value
      # puts "defaulting value to id: #{self.id}"
      # make sure we don't have any recursive callbacks
      self.update_column(:value, self.id)
    end
  end

end
