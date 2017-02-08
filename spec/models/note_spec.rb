require 'rails_helper'

describe Note do
  it 'has a valid factory' do
    expect(create(:note)).to be_valid
  end

  it 'can not be created without a notable' do
    expect{ create(:note, notable: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
