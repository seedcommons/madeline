class Currency < ActiveRecord::Base

  # create_table :currencies do |t|
  #   t.string :name
  #   t.string :code
  #   t.string :symbol
  #   t.string :short_symbol # do we really need this?  not sure when we'd want to display an unqualified currency symbol
  #   #todo once dependent functionality flushed out
  #   #t.decimal :current_exchange_rate, precision: 12, scale: 4
  #   t.timestamps null: false

end
