require 'rails_helper'

describe Accounting::LineItem do
  it 'has a valid factory' do
    expect(create(:line_item)).to be_valid
  end
end
