FactoryBot.define do
  factory :accounting_qb_department, class: 'Accounting::QB::Department', aliases: [:department] do
    sequence(:qb_id)
    sequence(:name) { |n| "Department #{n}" }
  end
end
