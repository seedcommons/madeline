shared_examples_for 'mediable' do
  let(:media_model) { create(described_class.to_s.underscore) }
  before do
    @table_name = media_model.class.table_name
    @id = media_model.id
  end

  context 'with no explicit priorities' do
    before do
      create_list(:media, 5, context_table: @table_name, context_id: @id)
    end

    it 'gets single media item for model with default options' do
      media = media_model.get_media(@table_name, @id)
      expect(media.size).to eq 1
    end

    it 'respects media limit when passed explicitly' do
      media = media_model.get_media(@table_name, @id, limit = 3)
      expect(media.size).to eq 3
    end
  end

  context 'with non-image media' do
    before do
      create_list(:media, 3, context_table: @table_name, context_id: @id)
      create(:media, context_table: @table_name, context_id: @id, media_path: 'http://example.com/files/movie.avi')
    end
    it 'gets only images when flag is set to true' do
      media = media_model.get_media(@table_name, @id, limit = 10, images_only = true)
      expect(media.size).to eq 3
    end
  end

  context 'with explicit priorities' do
    before do
      media = {
        'null' => create(:media, context_table: @table_name, context_id: @id, priority: nil),
        'zero' => create(:media, context_table: @table_name, context_id: @id, priority: 0),
        'priority-11' => create(:media, context_table: @table_name, context_id: @id, priority: 11),
        'priority-33a' => create(:media, context_table: @table_name, context_id: @id, priority: 33,
          media_path: Faker::Avatar.image('a')),
        'priority-33b' => create(:media, context_table: @table_name, context_id: @id, priority: 33,
          media_path: Faker::Avatar.image('b'))
      }

      @sorted_items = [media['priority-11'], media['priority-33a'], media['priority-33b'], media['zero'], media['null']]
    end

    it 'sorts items by null priority, zero priority, set priority then path' do
      media = media_model.get_media(@table_name, @id, limit = 5)
      expect(media.to_a).to eq @sorted_items
    end
  end

end
