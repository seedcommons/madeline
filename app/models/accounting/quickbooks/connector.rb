module Accounting
  module Quickbooks
    class Connector
      def initialize(custom_data = {})
        @custom_data = custom_data
      end

      def connected?
        !expired? &&
          token.present? &&
          secret.present? &&
          realm_id.present?
      end

      def expired?
        return token_expires_at < DateTime.now.utc if token_expires_at
        false
      end

      def renewable?
        return token_expires_at < 30.days.from_now.utc if token_expires_at && connected?
        false
      end

      def connect(access_token:, params:)
        root = Division.root
        root.custom_data = { quickbooks: {
          token: access_token.token,
          secret: access_token.secret,
          realm_id: params['realmId'],
          token_expires_at: 180.days.from_now.utc
        } }
        root.save!
        @custom_data = root.custom_data
      end

      def disconnect
        root = Division.root
        root.custom_data = { quickbooks: {} }
        root.save!
        @custom_data = root.custom_data
      end

      def access_token
        OAuth::AccessToken.new(QB_OAUTH_CONSUMER, token, secret)
      end

      def realm_id
        data[:realm_id] unless data.blank?
      end

      private

      def data
        @custom_data.with_indifferent_access[:quickbooks] unless @custom_data.blank?
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
