class Admin::QuickbooksController < Admin::AdminController
  def authenticate
    authorize :quickbooks, :authenticate?

    callback = oauth_callback_admin_quickbooks_url
    token = QB_OAUTH_CONSUMER.get_request_token(oauth_callback: callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}")
  end

  def oauth_callback
    authorize :quickbooks, :oauth_callback?

    at = Marshal.load(session[:qb_request_token]).get_access_token(oauth_verifier: params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']

    Division.root.quickbooks_connect(request_token: at, params: params)

    flash[:notice] = 'Your QuickBooks account has been successfully linked.'
  end

  def disconnect
    authorize :quickbooks, :disconnect?

    Division.root.quickbooks_disconnect

    redirect_to admin_settings_path, notice: 'Your QuickBooks account has been successfully disconnected.'
  end
end
