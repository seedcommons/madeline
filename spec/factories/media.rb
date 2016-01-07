FactoryGirl.define do
  factory :media do
    item { File.open(Rails.root.join('spec', 'support', 'assets', 'images', 'the swing.jpg')) }
  end
end
