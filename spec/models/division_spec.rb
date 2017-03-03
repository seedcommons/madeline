# == Schema Information
#
# Table name: divisions
#
#  accent_fg_color    :string
#  accent_main_color  :string
#  banner_bg_color    :string
#  banner_fg_color    :string
#  created_at         :datetime         not null
#  currency_id        :integer
#  custom_data        :json
#  description        :text
#  id                 :integer          not null, primary key
#  internal_name      :string
#  locales            :json
#  logo_content_type  :string
#  logo_file_name     :string
#  logo_file_size     :integer
#  logo_text          :string
#  logo_updated_at    :datetime
#  name               :string
#  notify_on_new_logs :boolean          default(FALSE)
#  organization_id    :integer
#  parent_id          :integer
#  quickbooks_data    :json
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_divisions_on_currency_id      (currency_id)
#  index_divisions_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_648c512956  (organization_id => organizations.id)
#  fk_rails_99cb2ea4ed  (currency_id => currencies.id)
#

require 'rails_helper'

describe Division, :type => :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end

  it 'can only have one root' do
    root_division
    expect { create(:division, parent: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
