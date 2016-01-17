require 'rails_helper'

describe CustomFieldSet, :type => :model do

  # was getting an "Language code: EN not found" error without ensure that is was created here
  # but not sure why this class is different from others like Note, ProjectStep, etc
  before { Language.system_default }

  it_should_behave_like 'translatable', ['label']

  it 'has a valid factory' do
    expect(create(:custom_field_set)).to be_valid
  end

end

