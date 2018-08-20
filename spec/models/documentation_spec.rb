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

require 'rails_helper'

describe Documentation, type: :model do
  it_should_behave_like 'translatable', ['summary_content', 'page_content']

  it 'has a valid factory' do
    expect(create(:documentation)).to be_valid
  end
end
