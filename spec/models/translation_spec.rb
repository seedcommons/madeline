# == Schema Information
#
# Table name: translations
#
#  created_at             :datetime
#  id                     :integer          not null, primary key
#  locale                 :string
#  text                   :text
#  translatable_attribute :string
#  translatable_id        :integer
#  translatable_type      :string
#  updated_at             :datetime
#
# Indexes
#
#  index_translations_on_translatable_type_and_translatable_id  (translatable_type,translatable_id)
#

require 'rails_helper'

describe Translation, :type => :model do
  it 'has a valid factory' do
    expect(create(:translation)).to be_valid
  end
end
