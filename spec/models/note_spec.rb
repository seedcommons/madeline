# == Schema Information
#
# Table name: notes
#
#  author_id    :integer
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  notable_id   :integer
#  notable_type :string
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_notes_on_author_id                    (author_id)
#  index_notes_on_notable_type_and_notable_id  (notable_type,notable_id)
#

require 'rails_helper'

describe Note do
  it 'has a valid factory' do
    expect(create(:note)).to be_valid
  end

  it 'can not be created without a notable' do
    expect{ create(:note, notable: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
