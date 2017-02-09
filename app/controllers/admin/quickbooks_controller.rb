class Admin::QuickbooksController < Admin::AdminController
  def authenticate
    authorize :quickbooks, :authenticate?

    # callback = quickbooks_oauth_callback_url
    callback = oauth_callback_admin_quickbooks_url
    token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    authorize :quickbooks, :oauth_callback?

    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params['realmId']

    puts "token: #{at.token}"
    puts "secrect: #{at.secret}"
    puts "realmid: #{params['realmId']}"
    # store the token, secret & RealmID somewhere for this user, you will need all 3 to work with Quickbooks-Ruby

   flash[:notice] = 'Your QuickBooks account has been successfully linked.'
  end
end

