
shared_examples_for 'custom_value_set_linkable' do |attr_params_list|
  let(:model_instance) { create(described_class.to_s.underscore) }


  it 'can autocreate dynamic attribute' do
    attr_params_list.each do |attr_params|
      attr_name = attr_params[:attr_name]
      field_set_name = attr_params[:field_set_name] || attr_name
      create(:custom_field_set, :generic_fields, internal_name: field_set_name)
      fetched = model_instance.send(attr_name, { autocreate: true })
      expect(fetched).to be_kind_of CustomValueSet
    end
  end

  it 'can suppress autocreation' do
    attr_params_list.each do |attr_params|
      attr_name = attr_params[:attr_name]
      field_set_name = attr_params[:field_set_name] || attr_name
      create(:custom_field_set, :generic_fields, internal_name: field_set_name)
      fetched = model_instance.send(attr_name)
      expect(fetched).to be_nil
    end
  end

  it 'can get and set custom values' do
    attr_params_list.each do |attr_params|
      attr_name = attr_params[:attr_name]
      field_set_name = attr_params[:field_set_name] || attr_name
      create(:custom_field_set, :generic_fields, internal_name: field_set_name)
      custom_value_set = model_instance.send(attr_name.to_sym, { autocreate: true })
      value = 'brown cow'
      #custom_value_set.update_custom_value('a_string', value)
      custom_value_set.a_string__text = value
      custom_value_set.save

      fetched = described_class.find(model_instance.id).send(attr_name)
      #expect(fetched.custom_value('a_string')).to eq value
      expect(fetched.a_string.text).to eq value
    end
  end



end

