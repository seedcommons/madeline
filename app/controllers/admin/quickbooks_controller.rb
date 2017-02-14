class Admin::QuickbooksController < Admin::AdminController
  def authenticate
    authorize :quickbooks, :authenticate?

    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{qb_request_token}")
  end

  def oauth_callback
    authorize :quickbooks, :oauth_callback?
    @header_disabled = true

    Division.root.quickbooks_connect(access_token: qb_access_token, params: params)

    flash[:notice] = 'Your QuickBooks account has been successfully linked.'
  end

  def disconnect
    authorize :quickbooks, :disconnect?

    Division.root.quickbooks_disconnect

    redirect_to admin_settings_path, notice: 'Your QuickBooks account has been successfully disconnected.'
  end

  private

  def qb_oauth_consumer
    Quickbooks.sandbox_mode = Rails.env.production?

    oauth_consumer_key = ENV.fetch('QB_OAUTH_CONSUMER_KEY')
    oauth_consumer_secret = ENV.fetch('QB_OAUTH_CONSUMER_SECRET')

    OAuth::Consumer.new(oauth_consumer_key, oauth_consumer_secret,
      site: 'https://oauth.intuit.com',
      request_token_path: '/oauth/v1/get_request_token',
      authorize_url: 'https://appcenter.intuit.com/Connect/Begin',
      access_token_path: '/oauth/v1/get_access_token'
    )
  end

  def qb_request_token
    callback = oauth_callback_admin_quickbooks_url
    request_token = qb_oauth_consumer.get_request_token(oauth_callback: callback)

    session[:qb_request_token] = Marshal.dump(request_token)
    request_token.token
  end

  def qb_access_token
    Marshal.load(session[:qb_request_token]).get_access_token(oauth_verifier: params[:oauth_verifier])
  end
end
