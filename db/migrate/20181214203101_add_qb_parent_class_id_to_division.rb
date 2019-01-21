# Quickbooks has a 'class' attribute on transactions. These can have parent classes.
# Madeline assigns each transaction it makes a quickbooks class, and that
# class is assigned the parent class associated with the division.

class AddQbParentClassIdToDivision < ActiveRecord::Migration[5.2]
  def change
    add_column :divisions, :qb_parent_class_id, :string
  end
end
