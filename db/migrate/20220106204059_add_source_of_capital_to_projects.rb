class AddSourceOfCapitalToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :source_of_capital_value, :string, default: 'shared', null: false
  end
end
