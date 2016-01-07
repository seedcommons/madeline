class OrganizationSnapshot < ActiveRecord::Base
  belongs_to :organization


  def name
    "#{date} - #{organization_size}/#{women_ownership_percent}/#{poc_ownership_percent}/#{environmental_impact_score}"
  end

end
