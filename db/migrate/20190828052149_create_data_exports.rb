class CreateDataExports < ActiveRecord::Migration[5.2]
  def change
    create_table :data_exports do |t|
      t.references :division, foreign_key: true, null: false
      t.string :name, null: false
      t.datetime :start_date
      t.datetime :end_date
      t.string :locale_code, null: false
      t.json :data
      t.string :type, null: false

      t.timestamps
    end
  end
end
