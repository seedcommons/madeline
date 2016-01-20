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

# Beware, many test cases would likely fail if the default system locale was not English
# todo: confirm if better to use Language.system_default instead of this factory helper
def get_language
  Language.first || create(:language)
end

FactoryGirl.define do
  factory :language do
    code 'EN'
    name 'English'
  end
end
