class Country < ApplicationRecord
  belongs_to :default_currency, class_name: 'Currency'

  def division
    Division.root # for permissions purposes, assume country model belongs to root division
  end
end
