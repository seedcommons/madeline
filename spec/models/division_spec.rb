require 'rails_helper'

describe Division, :type => :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end

  it 'can only have one root' do
    root_division
    expect { create(:division) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
