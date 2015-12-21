class Currency < ActiveRecord::Base
  def country
    Country.where(name: self.Country).first
  end
end
