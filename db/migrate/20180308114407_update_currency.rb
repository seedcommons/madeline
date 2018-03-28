class UpdateCurrency < ActiveRecord::Migration[5.1]
  def change
    add_column :currencies, :country_code, :string

    currencies = Currency.all
    currencies.each do |currency|
      update_values(currency)
      currency.save
    end
  end

  private

  def update_values(c)
    case c.code
      when 'ARS'
        c.short_symbol = '$'
        c.country_code ='AR'
      when 'USD'
        c.short_symbol = '$'
        c.country_code ='US'
      when 'GBP'
        c.short_symbol = '£'
        c.country_code ='GB'
      when 'NIO'
        c.short_symbol = 'C$'
        c.country_code ='NI'
    end
  end
end
