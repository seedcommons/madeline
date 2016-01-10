class Admin::Raw::PeopleController < BaseCrudController


  protected

  def clazz
    Person
  end

  # enabled special base class handling
  # should probably be factored out to a concern
  def division_scoped?
    true
  end


  # fields needed for initial model creation
  def create_attrs
    [:division_id, :first_name]
  end

  # full list of attributes which may be assigned from the form
  def update_attrs
    [:division_id, :first_name, :last_name,
     :dispay_name, :legal_name, :primary_phone, :secondary_phone, :fax, :email,
     :street_address, :neighborhood, :city, :state, :country, :country_id,
     :tax_no, :website, :contact_notes,
     :primary_organization, :primary_organization_id
    ]
  end


end
