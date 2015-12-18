require 'rails_helper'

describe Media, :type => :model do
  before { pending 're-implement in new project' }
  it_should_behave_like 'translatable', ['Caption']

  it 'has a valid factory' do
    expect(create(:media)).to be_valid
  end
end
