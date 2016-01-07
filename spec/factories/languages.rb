# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  code       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :language do
    code 'EN'
    name 'English'
  end
end
