FactoryBot.define do
  factory :accounting_qb_vendor, class: 'Accounting::QB::Vendor', aliases: [:vendor] do
    sequence(:qb_id)
    sequence(:name) { |n| "Vendor #{n}" }
  end
end
