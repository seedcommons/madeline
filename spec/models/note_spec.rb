require 'rails_helper'

describe Note do
  # beware, cannot test this concern without a valid default factory
  it_should_behave_like 'translatable', ['text']

  it 'has a valid factory' do
    expect(create(:note)).to be_valid
  end

  it 'can not be created without a notable' do
    expect{ create(:note, notable: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end


end
