def root_division
  Division.root
end

FactoryBot.define do
  factory :division do
    description { Faker::Lorem.sentence }
    name { Faker::Address.city }
    parent { root_division }
    public { true }

    trait :with_accounts do
      principal_account { create(:accounting_account, name: "Principal Account #{rand(1..9999)}") }
      interest_receivable_account { create(:accounting_account, name: "Interest Receivable #{rand(1..9999)}") }
      interest_income_account { create(:accounting_account, name: "Interest Income #{rand(1..9999)}") }

      # This is needed for Division#qb_division to work properly
      with_qb_connection
    end

    trait :with_qb_dept do
      qb_department { create(:department) }
    end

    trait :with_qb_connection do
      after(:create) do |division|
        division.qb_connection = create(
          :accounting_qb_connection,
          division: division,
          last_updated_at: Time.current
        )
      end
    end
  end
end

# Defines a global trait for models that delegate their divisions
# allowing us to assign them directly
FactoryBot.define do
  trait :transient_division do
    transient do
      division { nil }
    end

    after(:create) do |instance, evaluator|
      instance.division = evaluator.division if evaluator.division.present?
    end
  end
end
