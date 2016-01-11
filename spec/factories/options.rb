# == Schema Information
#
# Table name: options
#
#  id            :integer          not null, primary key
#  option_set_id :integer
#  position      :integer
#  value         :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_options_on_option_set_id  (option_set_id)
#

FactoryGirl.define do
  factory :option do
    option_set nil
position 1
value 1
  end

end
