FactoryBot.define do
  factory :accounting_sync_issue, class: 'Accounting::SyncIssue' do
    message { "There is an issue" }
  end
end
