# == Schema Information
#
# Table name: media
#
#  created_at            :datetime         not null
#  featured              :boolean          default(FALSE), not null
#  id                    :integer          not null, primary key
#  item                  :string
#  item_content_type     :string
#  item_file_size        :integer
#  item_height           :integer
#  item_width            :integer
#  kind_value            :string
#  media_attachable_id   :integer
#  media_attachable_type :string
#  sort_order            :integer
#  updated_at            :datetime         not null
#  uploader_id           :integer
#
# Indexes
#
#  index_media_on_media_attachable_type_and_media_attachable_id  (media_attachable_type,media_attachable_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploader_id => people.id)
#

require 'rails_helper'

describe Media, type: :model do

  context 'validations' do
    let(:media) { build(:media, kind_value: nil) }

    describe 'valid' do
      it 'has a valid factory' do
        expect(create(:media)).to be_valid
      end
    end

    describe 'invalid' do
      it 'is not valid' do
        expect(media).not_to be_valid
      end

      it 'raises errors for image without kind' do
        expect{
          create(:media, kind_value: nil)
        }.to raise_error("Validation failed: Kind can't be blank, Item please reattach your image")
      end

      it 'raises errors for kind without image' do
        expect{
          create(:media, item: nil)
        }.to raise_error("Validation failed: Item can't be blank")
      end
    end
  end
end
