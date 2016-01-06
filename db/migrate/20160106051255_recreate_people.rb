class RecreatePeople < ActiveRecord::Migration
  def change
    # note, wasn't able to just drop and re-add table because of foreign key constraints
    # (and apparently with postgres, there is no way to temporarily suspend the constraints)
    # drop_table :people
    # create_table :people do |t|
    #   ## base Contact fields
    #   t.references :division, index: true
    #   t.string :name   # note agreeing with mel's change of this from 'display_name' as a more consistent field to hold the full name
    #   t.string :legal_name
    #   t.string :primary_phone
    #   t.string :secondary_phone
    #   t.string :fax
    #   t.string :email
    #   t.text :street_address
    #   t.string :city
    #   t.string :neighborhood
    #   t.string :state
    #   t.references :country
    #   t.string :tax_no
    #   t.string :website
    #   t.text :notes
    #   t.timestamps null: false
    #   ## distinct Person fields
    #   t.string :first_name
    #   t.string :last_name
    #   t.references :primary_organization, references: :organizations, index: true
    # end
    # add_foreign_key :people, :organizations, column: :primary_organization_id


    add_reference :people, :division, index: true, foreign_key: true
    #name
    add_column :people, :legal_name, :string
    add_column :people, :primary_phone, :string
    add_column :people, :secondary_phone, :string
    add_column :people, :fax, :string
    add_column :people, :email, :string
    add_column :people, :street_address, :text
    add_column :people, :city, :string
    add_column :people, :neighborhood, :string
    add_column :people, :state, :string
    add_reference :people, :country, foreign_key: true  #don't think we need an index here
    add_column :people, :tax_no, :string
    add_column :people, :website, :string
    add_column :people, :notes, :text
    add_column :people, :first_name, :string
    add_column :people, :last_name, :string
    #t.references :primary_organization, references: :organizations

  end


end
