class UpdateCountryForCoops < ActiveRecord::Migration[5.1]
  def up
    orgs = Organization.where(country: nil)

    orgs.each do |o|
      o.country = get_country_for(o)
      o.save
    end
  end

  def down
  end

  private

  def get_country_for(org)
    currency_id = org.division.currency_id
    return unless currency_id

    currency = Currency.find(currency_id)
    Country.find_by(iso_code: currency.country_code)
  end
end
