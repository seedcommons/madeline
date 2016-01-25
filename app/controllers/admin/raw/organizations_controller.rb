class Admin::Raw::OrganizationsController < BaseCrudController


  protected

  # enabled special base class handling
  # should probably be factored out to a concern
  def division_scoped?
    true
  end


  # fields needed for initial model creation
  def create_attrs
    [:division_id, :name]
  end

  # full list of attributes which may be assigned from the form
  def update_attrs
    [:division_id, :name,
     :primary_contact, :primary_contact_id,
     :legal_name, :primary_phone, :secondary_phone, :fax, :email,
     :street_address, :neighborhood, :city, :state, :country, :country_id,
     :tax_no, :website, :contact_notes,
     :alias, :sector, :industry, :referral_source,
     :organization_snapshot_id,
     :is_recovered  #todo: automatically include custom fields
    ]
  end



end
