class CreateDataExports < ActiveRecord::Migration[5.2]
  def change
    create_table :data_exports do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :locale_code
      t.json :custom_data
      t.string :type

      t.timestamps
    end
  end
end
