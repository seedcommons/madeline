class Admin::Accounting::QuickbooksController < Admin::AdminController
  def authenticate
    authorize :'accounting/quickbooks', :authenticate?

    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{qb_request_token}")
  end

  def oauth_callback
    authorize :'accounting/quickbooks', :oauth_callback?
    @header_disabled = true

    Accounting::Quickbooks::Connection.create_from_access_token(access_token: qb_access_token, division: Division.root, params: params)

    flash[:notice] = t('quickbooks.connection.link_message')
  end

  def disconnect
    authorize :'accounting/quickbooks', :disconnect?

    Division.root.qb_connection.destroy

    redirect_to admin_settings_path, notice: t('quickbooks.connection.disconnect_message')
  end

  def full_sync
    authorize :'accounting/quickbooks', :full_sync?

    ::Accounting::Quickbooks::FullFetcher.new.fetch_all

    redirect_to admin_settings_path, notice: t('quickbooks.connection.full_sync_message')
  end

  private

  def qb_consumer
    @qb_consumer ||= Accounting::Quickbooks::Consumer.new
  end

  def qb_request_token
    callback = oauth_callback_admin_accounting_quickbooks_url
    request_token = qb_consumer.request_token(oauth_callback: callback)
    session[:qb_request_token] = Marshal.dump(request_token)

    request_token.token
  end

  def qb_access_token
    qb_consumer.verify_access_token(qb_request_token: Marshal.load(session[:qb_request_token]), oauth_verifier: params[:oauth_verifier])
  end
end
