##
## JE todo: update this to work with the new Translatable module
##

shared_examples_for 'translatable' do |column_names|
  let(:translatable_model) { create(described_class.to_s.underscore) }
  context 'with translations' do
    before do
      column_names.each do |column_name|
        translatable_model.send("set_#{column_name}".to_sym, Faker::Lorem.sentence)
      end
    end


    it 'should give translation' do
      column_names.each do |column_name|
        getter_translation = translatable_model.send(column_name.to_sym)
        raw_translation = Translation.find_by({translatable_type: translatable_model.class.name, translatable_id: translatable_model.id,
                          translatable_attribute: column_name, language_id: Language.resolve_id(I18n.language_code)})
        expect(getter_translation).to eq raw_translation.text
      end

    end

    it 'should have method for column name that fetches translation' do
      column_names.each do |column_name|
        method = "#{column_name}_list".to_sym
        t = translatable_model.try(method)
        expect(t).to be_a Array
      end
    end

    ##JE todo
    # describe 'currency format' do
    #   include ActionView::Helpers::NumberHelper
    #   let(:currency) { translatable_model.try(:currency) }
    #   let(:amount) { translatable_model.try(:amount) }
    #
    #   it 'should return a formatted currency amount with tooltip false' do
    #     if currency && amount
    #       formatted_currency = translatable_model.currency_format(amount, currency, tooltip = false)
    #       expect(formatted_currency).to eq "#{formatted_symbol(currency.symbol)}#{formatted_amount(amount)}"
    #     end
    #   end
    #
    #   it 'should return html-formatted currency amount with tooltip true' do
    #     if currency && amount
    #       formatted_currency = translatable_model.currency_format(amount, currency, tooltip = true)
    #       html_string = %Q(<a href="#" onclick="return false" data-toggle="tooltip" class="currency_symbol" title="s">#{formatted_symbol(currency.symbol)}</a> #{formatted_amount(amount)})
    #       expect(formatted_currency).to eq html_string
    #     end
    #   end
    # end
  end
end

def formatted_amount(amount)
  amount_with_decimals = '%.2f' % amount
  formatted_amount = number_with_delimiter(amount_with_decimals, delimiter: ',')
end

def formatted_symbol(symbol)
  symbol.sub('$', ' $')
end
