class UpdateNicaraguanSymbol < ActiveRecord::Migration[5.1]
  def change
    nic_sym = Currency.find_by(name: 'Nicaraguan Cordoba')
    nic_sym.update_attribute(:symbol, 'NIC$')
  end
end
