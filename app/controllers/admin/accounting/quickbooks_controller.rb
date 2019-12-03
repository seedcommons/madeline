class Admin::Accounting::QuickbooksController < Admin::AdminController
  # Kicks off oauth flow by redirecting to Intuit with request token.
  def authenticate
    authorize :'accounting/quickbooks', :authenticate?
    redirect_uri = oauth_callback_admin_accounting_quickbooks_url
    grant_url = qb_consumer.auth_code.authorize_url(
      redirect_uri: redirect_uri,
      resposne_type: "code",
      state: SecureRandom.hex(12),
      scope: "com.intuit.quickbooks.accounting"
    )
    redirect_to grant_url
  end

  def oauth_callback
    authorize :'accounting/quickbooks', :oauth_callback?
    @header_disabled = true

    # Fetch and store the access token and other necessary authentication information.
    if params[:state]
      redirect_uri = oauth_callback_admin_accounting_quickbooks_url
      response = qb_consumer.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
      if response
        Accounting::Quickbooks::Connection.create(
          access_token: response.token,
          refresh_token: response.refresh_token,
          realm_id: params[:realmId],
          division: Division.root,
          token_expires_at: Time.zone.at(response.expires_at)
        )
      end
    end

    Task.create(
      job_class: FullFetcherJob,
      job_type_value: :full_fetcher,
      activity_message_value: 'fetching_quickbooks_data'
    ).enqueue(job_params: {division_id: current_division.qb_division.id})

    flash[:notice] = t('quickbooks.connection.link_message')
    flash[:alert] = t('quickbooks.connection.import_in_progress_message')
  end

  def disconnect
    authorize :'accounting/quickbooks', :disconnect?
    Division.root.qb_connection.destroy
    redirect_to admin_accounting_settings_path, notice: t('quickbooks.connection.disconnect_message')
  end

  def connected
    authorize :'accounting/quickbooks', :authenticate?
    @quickbooks_connected = Division.root.quickbooks_connected?
    render json: @quickbooks_connected
  end

  private

  def qb_consumer
    @qb_consumer ||= Accounting::Quickbooks::Consumer.new
  end
end
