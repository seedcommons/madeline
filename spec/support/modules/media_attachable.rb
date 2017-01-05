shared_examples_for 'media_attachable' do
  let(:owner_model) { create(described_class.to_s.underscore) }

  context 'with no explicit priorities' do
    before do
      create_list(:media, 5, media_attachable: owner_model)
    end

    it 'gets single media item for model with default options' do
      media = owner_model.get_media
      expect(media.size).to eq 1
    end

    it 'respects media limit when passed explicitly' do
      media = owner_model.get_media(limit: 3)
      expect(media.size).to eq 3
    end
  end

  context 'with non-image media' do
    before do
      create_list(:media, 3, media_attachable: owner_model)
      create(:media, media_attachable: owner_model, kind: 'video')
    end
    it 'gets only images when flag is set to true' do
      media = owner_model.get_media(limit: 10, images_only: true)
      expect(media.size).to eq 3
    end
  end

  context 'with explicit priorities' do
    before do
      media = {
        'null' => create(:media, media_attachable: owner_model, sort_order: nil),
        'zero' => create(:media,  media_attachable: owner_model, sort_order: 0),
        'sort_order-11' => create(:media, media_attachable: owner_model, sort_order: 11),
        'sort_order-33a' => create(:media, media_attachable: owner_model, sort_order: 33,
          remote_item_url: 'http://fixtures.sassafras.coop/pants1.png'),
        'sort_order-33b' => create(:media, media_attachable: owner_model, sort_order: 33,
          remote_item_url: 'http://fixtures.sassafras.coop/pants2.png')
      }

      @sorted_items = [media['sort_order-11'], media['sort_order-33a'], media['sort_order-33b'], media['zero'], media['null']]
    end

    it 'sorts items by null sort_order, zero sort_order, set sort_order then path' do
      media = owner_model.get_media(limit: 5)
      expect(media.to_a).to eq @sorted_items
    end
  end
end
