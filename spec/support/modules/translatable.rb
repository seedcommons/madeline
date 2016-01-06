##
## JE todo: update this to work with the new Translatable module
##

shared_examples_for 'translatable' do |column_names|
  let(:translatable_model) { create(described_class.to_s.underscore) }
  context 'with translations' do
    before do
      @translations = {}

      column_names.each do |column_name|
        @translations[column_name] = create(:translation, remote_column_name: column_name, remote_table: translatable_model.class.table_name, remote_id: translatable_model.id)
      end
    end


    it 'should give translation' do
      column_names.each do |column_name|
        translation = translatable_model.translation(column_name)
        expect(translation).to eq @translations[column_name]
      end
    end

    it 'should have method for column name that fetches translation' do
      column_names.each do |column_name|
        method = column_name.underscore.downcase.to_sym
        t = translatable_model.try(method)
        expect(t).to be_a Translation
      end
    end

    describe 'currency format' do
      include ActionView::Helpers::NumberHelper
      let(:currency) { translatable_model.try(:currency) }
      let(:amount) { translatable_model.try(:amount) }

      it 'should return a formatted currency amount with tooltip false' do
        if currency && amount
          formatted_currency = translatable_model.currency_format(amount, currency, tooltip = false)
          expect(formatted_currency).to eq "#{formatted_symbol(currency.symbol)}#{formatted_amount(amount)}"
        end
      end

      it 'should return html-formatted currency amount with tooltip true' do
        if currency && amount
          formatted_currency = translatable_model.currency_format(amount, currency, tooltip = true)
          html_string = %Q(<a href="#" onclick="return false" data-toggle="tooltip" class="currency_symbol" title="s">#{formatted_symbol(currency.symbol)}</a> #{formatted_amount(amount)})
          expect(formatted_currency).to eq html_string
        end
      end
    end
  end
end

def formatted_amount(amount)
  amount_with_decimals = '%.2f' % amount
  formatted_amount = number_with_delimiter(amount_with_decimals, delimiter: ',')
end

def formatted_symbol(symbol)
  symbol.sub('$', ' $')
end
