# == Schema Information
#
# Table name: organization_snapshots
#
#  id                         :integer          not null, primary key
#  organization_id            :integer
#  date                       :date
#  organization_size          :integer
#  women_ownership_percent    :integer
#  poc_ownership_percent      :integer
#  environmental_impact_score :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#
# Indexes
#
#  index_organization_snapshots_on_organization_id  (organization_id)
#

class OrganizationSnapshot < ActiveRecord::Base
  belongs_to :organization
  delegate :division, :division=, to: :organization

  def name
    "#{date} - #{organization_size}/#{women_ownership_percent}/#{poc_ownership_percent}/#{environmental_impact_score}"
  end

end
