class Admin::Raw::OrganizationSnapshotsController < BaseCrudController


  protected

  def clazz
    OrganizationSnapshot
  end


  # fields needed for initial model creation
  def create_attrs
    [:organization_id]
  end

  def update_attrs
    [:organization_id, :date, :organization_size, :women_ownership_percent, :poc_ownership_percent, :environmental_impact_score]
  end


end
