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
  delegate :division, :division=, to: :option_set

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label

  after_create :ensure_value_assigned

  def ensure_value_assigned
    unless value
      # puts "defaulting value to id: #{self.id}"
      # make sure we don't have any recursive callbacks
      self.update_column(:value, self.id)
    end
  end

end
