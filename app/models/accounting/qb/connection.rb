# Stores the access token and other necessary information necessary to authenticate
# Quickbooks API requests.
# Also responsible for determining if connection is still valid or expired.
class Accounting::QB::Connection < ApplicationRecord
  belongs_to :division

  def connected?
    !expired? && !invalid_grant
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
    if token_expires_at < Time.current
      refresh_token!
      return token_expires_at < Time.current
    else
      false
    end
  end

  def refresh_token!
    qb_consumer = Accounting::QB::Consumer.new.oauth_consumer
    oauth2_token = OAuth2::AccessToken.new(qb_consumer, self.access_token, {refresh_token: self.refresh_token})
    begin
      refreshed = oauth2_token.refresh!.to_hash
    rescue OAuth2::Error
      self.invalid_grant = true
      return false
    else
      self.access_token = refreshed[:access_token]
      self.refresh_token = refreshed[:refresh_token]
      self.token_expires_at = Time.zone.at(refreshed[:expires_at])
      self.last_updated_at = Time.current
      self.invalid_grant = false
      self.save!
      return true
    end
  end
end
