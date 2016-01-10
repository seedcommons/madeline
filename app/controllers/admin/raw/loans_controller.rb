class Admin::Raw::LoansController < BaseCrudController



  protected

  def clazz
    Loan
  end

  # enabled special base class handling
  # should probably be factored out to a concern
  def division_scoped?
    true
  end


  # fields needed for initial model creation
  def create_attrs
    [:division_id, :organization_id]
  end

  # full list of attributes which may be assigned from the form
  def update_attrs
    [
    :division_id, :organization_id, :organization_snapshot_id,
    :primary_agent_id, :secondary_agent_id, :representative_id,
    :name,
    :status_option_id, :project_type_option_id,
    :loan_type_option_id, :public_level_option_id, :currency_id,
    :amount, :rate, :length_months, :projected_return,
    :signing_date, :first_payment_date, :first_interest_payment_date, :target_end_date,
    :organization_size, :woman_ownership_percent, :poc_ownership_percent, :environmental_impact_score,
    :summary, :details,  # todo: support extra translations
    ]
  end


end



