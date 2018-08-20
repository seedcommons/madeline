# == Schema Information
#
# Table name: documentations
#
#  calling_action     :string
#  calling_controller :string
#  created_at         :datetime         not null
#  html_identifier    :string
#  id                 :integer          not null, primary key
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_documentations_on_html_identifier  (html_identifier) UNIQUE
#

require 'rails_helper'

describe Documentation, type: :model do
  it_should_behave_like 'translatable', %w(summary_content page_content)

  it 'has a valid factory' do
    expect(create(:documentation)).to be_valid
  end

  describe 'uniqueness of html identifier' do
    let!(:doc1) { create(:documentation, html_identifier: 'chocolate') }

    it 'can not have duplicate html identifiers' do
      expect {
        create(:documentation, html_identifier: 'chocolate')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
