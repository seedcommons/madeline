
shared_examples_for 'option_settable' do |attribute_names|

  before do
    root_division
  end

  let(:model_instance) { create(described_class.to_s.underscore) }

  #todo: confirm if it's reasonable to perform all of these tests for each class and attribute or sufficient to sample

  it 'class should give option sets' do
    attribute_names.each do |attribute_name|
      method = "#{attribute_name}_option_set".to_sym
      # puts("described_class.name: #{described_class.name}")
      expect(described_class.send(method)).to be_a OptionSet
    end
  end

  it 'class should give option lists' do
    attribute_names.each do |attribute_name|
      method = "#{attribute_name}_options".to_sym
      expect(described_class.send(method)).to be_a Array
    end
  end


  it 'class should give option values' do
    attribute_names.each do |attribute_name|
      method = "#{attribute_name}_option_values".to_sym
      expect(described_class.send(method)).to be_a Array
    end
  end


  it 'class should resolve labels' do
    attribute_names.each do |attribute_name|
      value = described_class.send("#{attribute_name}_option_values".to_sym).sample
      if value
        method = "#{attribute_name}_label".to_sym
        result = described_class.send(method, value, :en)
        # puts("#{described_class.name}.#{attribute_name} - value: #{value} - class resolved label: #{result}")
        expect(result).to be_a String
      end
    end
  end


  it 'model instance should give label' do
    attribute_names.each do |attribute_name|
      option_set = OptionSet.fetch(described_class, attribute_name)
      value = 'active'

      label = 'Active'
      option_set.options.create(label_translations: {I18n.locale => label}, value: value)
      model_instance.send("#{attribute_name}_value=", value)
      result = model_instance.send("#{attribute_name}_label")
      expect(result.to_s).to eq label
    end
  end


end
