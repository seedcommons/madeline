# -*- SkipSchemaAnnotations
FactoryGirl.define do
  factory :repayment do
    amount_due { rand(1..50000) }
    amount_paid { amount_due }
    interest_since_last_payment { rand(1..amount_due) }
    date_due { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    loan_id { create(:loan).id }

    trait :paid do
      date_paid { Faker::Date.between(date_due - 1.week, date_due + 1.week) }
    end

    trait :refinanced do
      date_refinanced { Faker::Date.between(Date.civil(2004, 01, 01), Date.today) }
    end
  end
end
