# == Schema Information
#
# Table name: options
#
#  id            :integer          not null, primary key
#  option_set_id :integer
#  value         :string
#  position      :integer
#  migration_id  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_options_on_option_set_id  (option_set_id)
#

class Option < ActiveRecord::Base
  include Translatable


  belongs_to :option_set

  # define accessor like convenience methods for the fields stored in the Translations table
  attr_translatable :label

end
