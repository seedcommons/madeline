
shared_examples_for 'custom_model_linkable' do |attribute_names|
  let(:model_instance) { create(described_class.to_s.underscore) }


  it 'can autocreate dynamic attribute' do
    attribute_names.each do |attribute_name|
      create(:custom_field_set, :generic_fields, internal_name: attribute_name)
      fetched = model_instance.send(attribute_name.to_sym)
      expect(fetched).to be_kind_of CustomModel
    end
  end

  it 'can suppress autocreation' do
    attribute_names.each do |attribute_name|
      create(:custom_field_set, :generic_fields, internal_name: attribute_name)
      fetched = model_instance.send(attribute_name.to_sym, { autocreate: false })
      expect(fetched).to be_nil
    end
  end

  it 'can get and set custom values' do
    attribute_names.each do |attribute_name|
      create(:custom_field_set, :generic_fields, internal_name: attribute_name)
      custom_model = model_instance.send(attribute_name.to_sym)
      value = 'brown cow'
      custom_model.update_custom_value('a_string', value)
      fetched = described_class.find(model_instance.id).send(attribute_name.to_sym)
      expect(fetched.custom_value('a_string')).to eq value
    end
  end



end

