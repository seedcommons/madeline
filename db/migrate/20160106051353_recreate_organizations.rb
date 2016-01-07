class RecreateOrganizations < ActiveRecord::Migration
  def change
    # note, wasn't able to just drop and re-add table because of foreign key constraints
    # drop_table :organizations
    # create_table :organizations do |t|
    #   ## base Contact fields
    #   t.references :division, index: true
    #   t.string :name  # note, also renamed from display_name
    #   t.string :legal_name
    #   t.string :primary_phone
    #   t.string :secondary_phone
    #   t.string :fax
    #   t.string :email
    #   t.text :street_address  # note, this existing data has some verbose directions stored in this field
    #   t.string :city
    #   t.string :neighborhood
    #   t.string :state
    #   t.references :country
    #   t.string :tax_no
    #   t.string :website
    #   t.text :notes
    #   ## distinct Organization fields
    #   t.string :alias
    #   t.references :primary_contact, references: :people
    #   t.string :sector
    #   t.string :industry
    #   t.string :referral_source
    #   t.references :organization_snapshot
    #   t.timestamps

    add_reference :organizations, :division, index: true, foreign_key: true
    #name
    remove_column :organizations, :display_name  # rename to keep consistent with people, etc
    add_column :organizations, :name, :string
    add_column :organizations, :legal_name, :string
    add_column :organizations, :primary_phone, :string
    add_column :organizations, :secondary_phone, :string
    add_column :organizations, :fax, :string
    add_column :organizations, :email, :string
    add_column :organizations, :street_address, :text
    add_column :organizations, :city, :string
    add_column :organizations, :neighborhood, :string
    add_column :organizations, :state, :string
    add_reference :organizations, :country, foreign_key: true  #don't think we need an index here
    add_column :organizations, :tax_no, :string
    add_column :organizations, :website, :string
    add_column :organizations, :notes, :text
    add_column :organizations, :alias, :string
    add_column :organizations, :last_name, :string
    add_reference :organizations, :organization_snapshot, foreign_key: false
    #t.references :primary_contact, references: :people
    add_column :organizations, :primary_contact_id, :integer
    add_foreign_key :organizations, :people, column: :primary_contact_id

  end

end
