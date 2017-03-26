module TransactionListable
  extend ActiveSupport::Concern

  def initialize_transactions_grid(project_id = nil)
    begin
      ::Accounting::Quickbooks::AccountFetcher.new.fetch
      ::Accounting::Quickbooks::TransactionFetcher.new.fetch
    rescue Quickbooks::ServiceUnavailable => e
      Rails.logger.error e
      flash.now[:error] = t('quickbooks.service_unavailable')
    rescue Quickbooks::AuthorizationFailure => e
      Rails.logger.error e
      flash.now[:error] = t('quickbooks.authorization_failure')
    rescue Quickbooks::InvalidModelException,
      Quickbooks::Forbidden,
      Quickbooks::ThrottleExceeded,
      Quickbooks::TooManyRequests,
      Quickbooks::MissingRealmError,
      Quickbooks::IntuitRequestException => e
      Rails.logger.error e
      ExceptionNotifier.notify_exception(e)
      flash.now[:error] = t('quickbooks.misc')
    end

    if project_id
      @transactions = ::Accounting::Transaction.where(project_id: project_id)
    else
      @transactions = ::Accounting::Transaction.all
    end

    @transactions_grid = initialize_grid(@transactions)
  end
end
