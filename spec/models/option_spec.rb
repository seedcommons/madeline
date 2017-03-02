# == Schema Information
#
# Table name: options
#
#  created_at    :datetime         not null
#  id            :integer          not null, primary key
#  migration_id  :integer
#  option_set_id :integer
#  position      :integer
#  updated_at    :datetime         not null
#  value         :string
#
# Indexes
#
#  index_options_on_option_set_id  (option_set_id)
#
# Foreign Keys
#
#  fk_rails_db3e5d5ea9  (option_set_id => option_sets.id)
#

require 'rails_helper'

describe Option, type: :model do

  it 'has a valid factory' do
    expect(create(:option)).to be_valid
  end

end
