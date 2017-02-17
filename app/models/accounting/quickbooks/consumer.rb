module Accounting
  module Quickbooks
    class Consumer
      def initialize
        oauth_consumer_key = ENV.fetch('QB_OAUTH_CONSUMER_KEY')
        oauth_consumer_secret = ENV.fetch('QB_OAUTH_CONSUMER_SECRET')

        @oauth_consumer = OAuth::Consumer.new(oauth_consumer_key, oauth_consumer_secret,
          site: 'https://oauth.intuit.com',
          request_token_path: '/oauth/v1/get_request_token',
          authorize_url: 'https://appcenter.intuit.com/Connect/Begin',
          access_token_path: '/oauth/v1/get_access_token'
        )
      end

      def request_token(oauth_callback:)
        @oauth_consumer.get_request_token(oauth_callback: oauth_callback)
      end

      def verify_access_token(qb_request_token:, oauth_verifier:)
        qb_request_token.get_access_token(oauth_verifier: oauth_verifier)
      end

      def access_token(token:, secret:)
        OAuth::AccessToken.new(@oauth_consumer, token, secret)
      end
    end
  end
end
