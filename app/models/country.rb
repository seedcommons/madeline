class Country < ActiveRecord::Base
  belongs_to :language, :foreign_key => 'LanguageID'
  belongs_to :default_currency, class_name: 'Currency'
end
