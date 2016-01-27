FactoryGirl.define do
  trait :with_language do
    after(:build) do |instance|
      # instance.language = Language.first || create(:language) unless instance.language.present?
      instance.language = get_language
    end
  end

  # trait :with_language_id do
  #   after(:build) do |instance|
  #     # instance.language = Language.first.try(:id) || create(:language).id unless instance.language.present?
  #     instance.language = get_language
  #   end
  # end
end
