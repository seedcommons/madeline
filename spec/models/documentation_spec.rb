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

  describe 'translations are saved properly' do
    before do
      doc.summary_content = 'summary'
      doc.page_content = 'page'
      doc.save
    end

    it 'saves' do
      expect(doc.reload.summary_content.text).to eq('summary')
      expect(doc.reload.page_content.text).to eq('page')
    end
  end
end
