class Currency < ActiveRecord::Base
  include Legacy

  def country
    Country.where(name: self.Country).first
  end
end
