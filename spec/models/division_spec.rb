# == Schema Information
#
# Table name: divisions
#
#  accent_fg_color                :string
#  accent_main_color              :string
#  banner_bg_color                :string
#  banner_fg_color                :string
#  closed_books_date              :date
#  created_at                     :datetime         not null
#  currency_id                    :integer
#  custom_data                    :json
#  description                    :text
#  id                             :integer          not null, primary key
#  interest_income_account_id     :integer
#  interest_receivable_account_id :integer
#  internal_name                  :string
#  locales                        :json
#  logo_content_type              :string
#  logo_file_name                 :string
#  logo_file_size                 :integer
#  logo_text                      :string
#  logo_updated_at                :datetime
#  name                           :string
#  notify_on_new_logs             :boolean          default(FALSE)
#  organization_id                :integer
#  parent_id                      :integer
#  principal_account_id           :integer
#  public                         :boolean          default(FALSE), not null
#  qb_id                          :string
#  qb_parent_class_id             :string
#  qb_read_only                   :boolean          default(TRUE), not null
#  short_name                     :string
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id                     (currency_id)
#  index_divisions_on_interest_income_account_id      (interest_income_account_id)
#  index_divisions_on_interest_receivable_account_id  (interest_receivable_account_id)
#  index_divisions_on_organization_id                 (organization_id)
#  index_divisions_on_principal_account_id            (principal_account_id)
#  index_divisions_on_short_name                      (short_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (currency_id => currencies.id)
#  fk_rails_...  (interest_income_account_id => accounting_accounts.id)
#  fk_rails_...  (interest_receivable_account_id => accounting_accounts.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (principal_account_id => accounting_accounts.id)
#

require 'rails_helper'

describe Division, type: :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end

  it 'can only have one root' do
    root_division
    expect { create(:division, parent: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'short name' do

    before { allow(SecureRandom).to receive(:uuid) {'iamauuid2018'} }

    let!(:division_1) { create(:division, name: 'trouble') }
    let!(:division_2) { create(:division, name: 'trouble', notify_on_new_logs: true) }
    let!(:division_3) { create(:division, name: '---') }

    it 'generates a short name if one is not provided' do
      expect(division_1.short_name).to eq('trouble')
    end

    it 'generates a short name for division with the same name' do
      expect(division_2.short_name).to eq('trouble-iamauuid2018')
    end

    it 'generates short name for division with just hyphens' do
      expect(division_3.short_name).to eq('-iamauuid2018')
    end
  end
end
