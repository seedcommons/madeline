class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.references :primary_organization, references: :organizations
      t.date :birth_date

      t.timestamps null: false
    end
    add_foreign_key :people, :organizations, column: :primary_organization_id
  end
end
