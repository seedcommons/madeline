FactoryBot.define do
  factory :accounting_line_item, class: 'Accounting::LineItem', aliases: [:line_item] do
    qb_line_id { 1 }
    association :parent_transaction, factory: :accounting_transaction
    association :account
    posting_type { ["credit", "debit"].sample }
    description { Faker::Hipster.sentence(4).chomp(".") }
    amount { Faker::Number.decimal(4, 2) }
  end

  factory :line_item_json, class: FactoryStruct do
    skip_create

    transient do
      account { nil }
      loan { create(:loan) }
      detail_type { "JournalEntryLineDetail" }
      posting_type { ['Credit', 'Debit'].sample }
    end

    sequence(:id, 0) { |n| n }
    amount { Faker::Number.decimal(2) }
    description { "#%010d" % rand(1..9999999999) }

    after(:build) do |li, evaluator|
      posting_type = evaluator.posting_type
      detail_type = evaluator.detail_type
      li.detail_type = detail_type

      detail_hash = {
        "entity" => {
          "type" => "Customer",
          "entity_ref" => { "value" => rand(1..999), "name" => Faker::App.name, "type" => nil }
        },
        "account_ref" => { "value" => evaluator.account.qb_id, "name" => evaluator.account.name, "type" => nil },
        "class_ref" => {
          "value" => (rand(1..99999) + 5000000000000000000),
          "name" => "Loan Products:Loan ID #{evaluator.loan.id}"
        },
        "department_ref" => nil
      }
      detail_hash.merge({"posting_type" => posting_type}) if posting_type.present? && detail_type == "JournalEntryLineDetail"

      li.send("#{detail_type.underscore}=", detail_hash)
    end
  end
end
