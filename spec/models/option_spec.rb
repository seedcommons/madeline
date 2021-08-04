require 'rails_helper'

describe Option, type: :model do

  it 'has a valid factory' do
    expect(create(:option)).to be_valid
  end

end
