require 'rails_helper'

describe ProjectLog, :type => :model do
  it 'has a valid factory' do
    expect(create(:project_log)).to be_valid
  end
end
