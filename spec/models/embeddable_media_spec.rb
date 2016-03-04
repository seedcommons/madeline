require 'rails_helper'

describe EmbeddableMedia, type: :model do

  it 'has a valid factory' do
    expect(create(:embeddable_media)).to be_valid
  end

end
