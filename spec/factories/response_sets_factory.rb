# == Schema Information
#
# Table name: response_sets
#
#  created_at   :datetime         not null
#  custom_data  :json
#  id           :integer          not null, primary key
#  kind         :string
#  loan_id      :integer          not null
#  lock_version :integer          default(0), not null
#  updated_at   :datetime         not null
#  updater_id   :integer
#
# Foreign Keys
#
#  fk_rails_...  (updater_id => users.id)
#

FactoryBot.define do
  factory :response_set do
    loan
    kind { 'criteria' }
  end
end
