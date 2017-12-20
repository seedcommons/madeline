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
#  index_options_on_value          (value)
#
# Foreign Keys
#
#  fk_rails_...  (option_set_id => option_sets.id)
#

FactoryBot.define do
  factory :option do
    option_set
    position 1
    value 'active'
    transient_division
  end

end
