class Admin::Accounting::QuickbooksController < Admin::AdminController
  # Kicks off oauth flow by redirecting to Intuit with request token.
  def authenticate
    authorize :'accounting/quickbooks', :authenticate?
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{fetch_qb_request_token}")
  end

  def oauth_callback
    authorize :'accounting/quickbooks', :oauth_callback?
    @header_disabled = true

    # Fetch and store the access token and other necessary authentication information.
    Accounting::Quickbooks::Connection.create_from_access_token(
      access_token: fetch_qb_access_token,
      division: Division.root,
      params: params
    )
    Accounting::Quickbooks::FullFetcher.new(current_division.qb_division).fetch_all

    flash[:notice] = t('quickbooks.connection.link_message')
  end

  def disconnect
    authorize :'accounting/quickbooks', :disconnect?
    Division.root.qb_connection.destroy
    redirect_to admin_settings_path, notice: t('quickbooks.connection.disconnect_message')
  end

  def full_sync
    authorize :'accounting/quickbooks', :full_sync?
    Accounting::Quickbooks::FullFetcher.new(current_division.qb_division).fetch_all
    redirect_to admin_settings_path, notice: t('quickbooks.connection.full_sync_message')
  end

  private

  def qb_consumer
    @qb_consumer ||= Accounting::Quickbooks::Consumer.new
  end

  # Gets a request token from Quickbooks, which is required to begin the oauth flow.
  # The request token encodes the oauth callback URL to which the user will be redirected once they
  # authenticate with Intuit.
  # Also stores the request token in the session so it can be used when getting an access token.
  def fetch_qb_request_token
    callback = oauth_callback_admin_accounting_quickbooks_url
    request_token = qb_consumer.request_token(oauth_callback: callback)
    session[:qb_request_token] = Marshal.dump(request_token)
    request_token.token
  end

  # Gets an access token from Quickbooks, which is what we actually use to do day-to-day API requests.
  def fetch_qb_access_token
    qb_consumer.verify_access_token(
      qb_request_token: Marshal.load(session[:qb_request_token]),
      oauth_verifier: params[:oauth_verifier]
    )
  end
end
