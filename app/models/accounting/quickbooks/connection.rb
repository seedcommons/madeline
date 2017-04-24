module Accounting
  module Quickbooks
    class Connection
      def initialize(quickbooks_data = {})
        @quickbooks_data = quickbooks_data
      end

      def connected?
        !expired? && token.present? && secret.present? && realm_id.present?
      end

      def expired?
        return token_expires_at < DateTime.now.utc if token_expires_at
        false
      end

      def renewable?
        return token_expires_at < 30.days.from_now.utc if token_expires_at && connected?
        false
      end

      def save(access_token:, params:)
        root = Division.root
        root.quickbooks_data = {
          token: access_token.token,
          secret: access_token.secret,
          realm_id: params['realmId'],
          token_expires_at: 180.days.from_now.utc
        }
        root.save!
        @quickbooks_data = root.quickbooks_data
      end

      def forget
        root = Division.root
        root.quickbooks_data = {}
        root.save!
        @quickbooks_data = root.quickbooks_data
      end

      def auth_details
        {access_token: access_token, company_id: realm_id}
      end

      def access_token
        Consumer.new.access_token(token: token, secret: secret)
      end

      def realm_id
        data[:realm_id] unless data.blank?
      end

      def last_updated_at
        DateTime.parse(data[:last_updated_at]) unless data.blank? || data[:last_updated_at].blank?
      end

      def last_updated_at=(date)
        root = Division.root
        root.quickbooks_data = data.merge(last_updated_at: date)
        root.save!
        @quickbooks_data = root.quickbooks_data
      end

      private

      def data
        @quickbooks_data.with_indifferent_access unless @quickbooks_data.blank?
      end

      def token
        data[:token] unless data.blank?
      end

      def secret
        data[:secret] unless data.blank?
      end

      def token_expires_at
        data[:token_expires_at] unless data.blank?
      end
    end
  end
end
