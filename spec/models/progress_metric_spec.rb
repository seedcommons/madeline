require 'rails_helper'

describe ProgressMetric, :type => :model do
  before { pending 're-implement in new project' }
  it 'has a valid factory' do
    expect(create(:progress_metric)).to be_valid
  end
end
