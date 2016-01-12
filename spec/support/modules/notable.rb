shared_examples_for 'notable' do
  let(:notable_model) { create(described_class.to_s.underscore) }
  let(:text) { Faker::Lorem.sentence }
  context 'with note' do
    before do
      notable_model.add_note(text, create(:person))
    end

    it 'should add and return matching text' do
      expect(notable_model.notes.first.text).to eq(text)
    end

  end
end

