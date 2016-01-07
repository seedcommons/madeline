class AlterCountries < ActiveRecord::Migration
  def change
    add_column :countries, :name, :string
    # add_references doesn't seem to let me specify a different name
    # add_reference :countries, :default_language, references: :languages, index: true, foreign_key: true
    add_column :countries, :default_language_id, :integer
    add_foreign_key :countries, :languages, column: :default_language_id

  end
end
