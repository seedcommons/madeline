class AddClosedBookDateToDivision < ActiveRecord::Migration[5.2]
  def change
    add_column :divisions, :closed_books_date, :date
  end
end
