class RemoveCodeFromLanguages < ActiveRecord::Migration
  def change
    remove_column :languages, :code, :string
  end
end
