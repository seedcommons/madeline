require 'rails_helper'

describe Note, :type => :model do

# beware, cannot test this concern without a valid default factory
#  it_should_behave_like 'translatable', ['text']

  # beware, Note does not have a valid generic factory
  # it 'has a valid factory' do
  #   expect(create(:note)).to be_valid
  # end

  it 'can be created from a notable' do
    person = create(:person)
    note = create(:note, author: person)
    expect(note).to be_valid
    expect(note.text).to be_present
  end

  it 'has text populated by factory' do
    person = create(:person)
    note = create(:note, author: person)
    expect(note.text).to be_present
  end

  it 'can not be created without a notable' do
    # it seems that from the console, Note.create() successfully returns an invid object,
    # but the factory girl create(:note) throws an exception
    # expect(create(:note)).to_not be_valid
    expect{ create(:note) }.to raise_error(ActiveRecord::RecordInvalid)
  end


end
