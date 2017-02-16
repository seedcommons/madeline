class Admin::QuickbooksController < Admin::AdminController
  def authenticate
    authorize :quickbooks, :authenticate?

    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{qb_request_token}")
  end

  def oauth_callback
    authorize :quickbooks, :oauth_callback?
    @header_disabled = true

    Division.root.quickbooks_save(access_token: qb_access_token, params: params)

    flash[:notice] = 'Your QuickBooks account has been successfully linked.'
  end

  def disconnect
    authorize :quickbooks, :disconnect?

    Division.root.quickbooks_forget

    redirect_to admin_settings_path, notice: 'Your QuickBooks account has been successfully disconnected.'
  end

  private

  def qb_consumer
    @qb_consumer ||= Accounting::Quickbooks::Consumer.new
  end

  def qb_request_token
    callback = oauth_callback_admin_quickbooks_url
    request_token = qb_consumer.request_token(oauth_callback: callback)
    session[:qb_request_token] = Marshal.dump(request_token)

    request_token.token
  end

  def qb_access_token
    qb_consumer.verify_access_token(qb_request_token: Marshal.load(session[:qb_request_token]), oauth_verifier: params[:oauth_verifier])
  end
end
