# Handles authenticating to the Quickbooks API. Depends on the consumer key and secret ENV vars.
# The project Readme contains detailed instructions on how to configure these.
# See Quickbooks::Connection for details on how authentication information is stored.
module Accounting
  module QB
    class Consumer
      def initialize
        if ::Quickbooks.sandbox_mode
          oauth_consumer_key = ENV.fetch('QB_SANDBOX_OAUTH2_CLIENT_ID')
          oauth_consumer_secret = ENV.fetch('QB_SANDBOX_OAUTH2_CLIENT_SECRET')
        else
          oauth_consumer_key = ENV.fetch('QB_OAUTH2_CLIENT_ID')
          oauth_consumer_secret = ENV.fetch('QB_OAUTH2_CLIENT_SECRET')
        end

        @oauth_consumer = OAuth2::Client.new(oauth_consumer_key, oauth_consumer_secret,
          site: "https://appcenter.intuit.com/connect/oauth2",
          authorize_url: "https://appcenter.intuit.com/connect/oauth2",
          token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer")
      end

      def oauth_consumer
        @oauth_consumer
      end
      delegate :auth_code, to: :oauth_consumer
    end
  end
end
