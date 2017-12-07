require 'rails_helper'

describe BasicProject, type: :model do
  it_should_behave_like 'translatable', ['summary', 'details']
  it_should_behave_like 'option_settable', ['status']

  it 'has a valid factory' do
    expect(create(:basic_project)).to be_valid
  end
end
