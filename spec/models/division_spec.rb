require 'rails_helper'

describe Division, :type => :model do
  before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end
end
