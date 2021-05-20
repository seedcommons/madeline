# == Schema Information
#
# Table name: accounting_qb_connections
#
#  access_token     :string
#  created_at       :datetime         not null
#  division_id      :integer          not null
#  id               :integer          not null, primary key
#  last_updated_at  :datetime
#  realm_id         :string           not null
#  refresh_token    :string
#  token_expires_at :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounting_qb_connections_on_division_id  (division_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

# Stores the access token and other necessary information necessary to authenticate
# Quickbooks API requests.
# Also responsible for determining if connection is still valid or expired.
class Accounting::QB::Connection < ApplicationRecord
  belongs_to :division

  def connected?
    !expired? && access_token && refresh_token && realm_id
  end

  def token
    qb_access_token = self.access_token
    qb_refresh_token = self.refresh_token
    qb_consumer = Accounting::QB::Consumer.new.oauth_consumer
    oauth2_token = OAuth2::AccessToken.new(qb_consumer, qb_access_token, {:refresh_token => qb_refresh_token})
    oauth2_token
  end

  def auth_details
    {access_token: token, company_id: realm_id}
  end

  def company_name
    begin
      company_info_service = ::Quickbooks::Service::CompanyInfo.new(self.auth_details)
      query_result = company_info_service.query("select * from CompanyInfo")
      if query_result.entries.present?
        query_result.entries.first.company_name
      else
        "Unknown"
      end
    rescue StandardError
      # don't handle error if unable to get company name
      "Unknown"
    end
  end

  private

  def expired?
    if token_expires_at < Time.zone.now
      refresh_token!
      return token_expires_at < Time.zone.now
    else
      false
    end
  end

  def refresh_token!
    qb_consumer = Accounting::QB::Consumer.new.oauth_consumer
    oauth2_token = OAuth2::AccessToken.new(qb_consumer, self.access_token, {refresh_token: self.refresh_token})
    refreshed = oauth2_token.refresh!.to_hash
    self.access_token = refreshed[:access_token]
    self.refresh_token = refreshed[:refresh_token]
    self.token_expires_at = Time.zone.at(refreshed[:expires_at])
    self.save!
  end
end
