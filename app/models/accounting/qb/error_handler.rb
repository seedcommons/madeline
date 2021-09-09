
module Accounting
  module QB
    class ErrorHandler

      def initialize(loan, in_background_job: false)
        @loan = loan
        @in_background_job = in_background_job
      end

      # Runs the given block and handles any Quickbooks errors.
      # Returns the error message (potentially with HTML) as a string if there was an error, else returns nil.
      # Notifies admins if error is not part of normal operation.

      def handle_qb_errors
        begin
          yield
        rescue Quickbooks::ServiceUnavailable => e
          if @in_background_job
            # This is an error b/c we may have been in the middle of creating interest txns
            Accounting::SyncIssue.create!(level: :error, loan: @loan, message: :quickbooks_unavailable_recalc)
            raise if @in_background_job # If QB is down, no point in continuing, so re-raise
          else
            Rails.logger.error e
            error_msg = I18n.t("quickbooks.service_unavailable")
          end
        rescue Accounting::QB::DataResetRequiredError => e
          Rails.logger.error e
          error_msg = I18n.t("quickbooks.data_reset_required", settings: settings_link).html_safe
        rescue Accounting::QB::UnprocessableAccountError => e
          Accounting::SyncIssue.create!(loan: e.loan, accounting_transaction: e.transaction,
                                        message: :unprocessable_account, level: :error, custom_data: {})
        rescue Accounting::QB::IntuitRequestError => e
          txn = e.transaction
          is_matching_error = e.message.include?("matched to a downloaded transaction")
          intuit_error_type = is_matching_error ? :matched_transaction : :unknown_intuit_request_exception
          Accounting::SyncIssue.create!(loan: txn.loan,
                                        accounting_transaction: txn,
                                        message: intuit_error_type,
                                        level: :warning, # want to still see ledger
                                        custom_data: {date: txn.txn_date, qb_id: txn.qb_id})
          changes_hash = {txn_changes: txn.previous_changes,
                          line_item_changes: txn.line_items.map { |li| li.previous_changes }}
          Rails.logger.error("Accounting::QB::IntuitRequestError #{intuit_error_type} #{e.message}. Txn date: #{txn.txn_date}. Txn qb id: #{txn.qb_id}. Changes: #{changes_hash}")
          error_msg = I18n.t("quickbooks.#{intuit_error_type}",
                        date: txn.txn_date,
                        qb_id: txn.qb_id)
        rescue Quickbooks::MissingRealmError,
               Accounting::QB::NotConnectedError,
               Quickbooks::AuthorizationFailure => e
          Rails.logger.error e
          error_msg = I18n.t("quickbooks.authorization_failure", settings: settings_link).html_safe
        rescue Quickbooks::InvalidModelException,
               Quickbooks::Forbidden,
               Quickbooks::ThrottleExceeded,
               Quickbooks::TooManyRequests,
               Quickbooks::IntuitRequestException => e
          Rails.logger.error e
          ExceptionNotifier.notify_exception(e)
          error_msg =I18n.t("quickbooks.misc", msg: e)
        rescue Accounting::QB::NegativeBalanceError => e
          Rails.logger.error e
          error_msg =I18n.t("quickbooks.negative_balance", amt: e.prev_balance)
        rescue StandardError => e
          # If there is an unhandled error updating an individual loan, we don't want the whole process to fail.
          # We let the user know that there was a system error and we've been notified.
          # But we don't expose the original error message to the user since it won't be intelligble
          # and could be a security issue.
          Accounting::SyncIssue.create!(level: :error, loan: @loan, message: :system_error_recalc)
          # We want to receive a loud notification about an unhandled error.
          # If we find this is often generating a lot of similar errors
          # then we should really start using Sentry or some other service to group them.
          notify_of_error(e, data: {context: "Unhandled error during loan update", loan_id: @loan.id})
        end
        error_msg # used in transactions controller but not in QuickbooksUpdateJob
      end
    end
  end
end
