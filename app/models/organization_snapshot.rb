class OrganizationSnapshot < ActiveRecord::Base

  # create_table :organization_snapshots do |t|
  #   t.references :organization, index: true
  #   t.date :date
  #   t.integer :organization_size
  #   t.integer :women_ownership_percent
  #   t.integer :poc_ownership_percent
  #   t.integer :environmental_impact_score
  #   t.timestamps

  belongs_to :organization


  def name
    "#{date} - #{organization_size}/#{women_ownership_percent}/#{poc_ownership_percent}/#{environmental_impact_score}"
  end

end
