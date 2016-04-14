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

FactoryGirl.define do
  factory :option do
    option_set
    position 1
    value 'active'
    transient_division
  end

end
