class Country < ActiveRecord::Base
  belongs_to :language, :foreign_key => 'LanguageID'

  def default_currency
    Currency.where(:Country => self.name).first
  end
end
