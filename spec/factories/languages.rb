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
    locale { I18n.default_locale }
    name 'English'
  end
end
