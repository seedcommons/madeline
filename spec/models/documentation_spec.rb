require 'rails_helper'

describe Documentation, type: :model do
  let!(:doc) { create(:documentation, html_identifier: 'chocolate') }

  it_should_behave_like 'translatable', %w(summary_content page_content)

  it 'has a valid factory' do
    expect(create(:documentation)).to be_valid
  end

  describe 'uniqueness of html identifier' do
    it 'can not have duplicate html identifiers' do
      expect {
        create(:documentation, html_identifier: 'chocolate')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
