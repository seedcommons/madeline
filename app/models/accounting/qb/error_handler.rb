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
        rescue  Accounting::QB::DataResetRequiredError,
                Accounting::QB::NotConnectedError,
                Accounting::QB::AccountsNotSelectedError,
                Quickbooks::ServiceUnavailable,
                Quickbooks::MissingRealmError,
                Quickbooks::AuthorizationFailure,
                Quickbooks::ThrottleExceeded,
                Quickbooks::TooManyRequests => e
          Rails.logger.error e
          ExceptionNotifier.notify_exception(e)
          # TODO change message based on error
          Accounting::SyncIssue.create!(level: :error, loan: nil, message: :quickbooks_unavailable_recalc)
          if @in_background_job
            # any of the above issues mean the bg job should stop
            raise
          else
            # in controller, so return error message to be displayed
            return error_msg = case e
                               when Accounting::QB::DataResetRequiredError
                                 I18n.t("quickbooks.data_reset_required", settings: settings_link).html_safe
                               when Quickbooks::AuthorizationFailure, Quickbooks::MissingRealmError, Accounting::QB::NotConnectedError
                                 I18n.t("quickbooks.authorization_failure", msg: e)
                               when Quickbooks::ServiceUnavailable
                                 I18n.t("quickbooks.service_unavailable", msg: e)
                               else
                                 I18n.t("quickbooks.misc", msg: e)
                               end
          end
        rescue Accounting::QB::UnprocessableAccountError,
               Accounting::QB::NegativeBalanceError => e
          Rails.logger.error e
          ExceptionNotifier.notify_exception(e)
          message = case e
                    when Accounting::QB::UnprocessableAccountError
                      t("quickbooks.unprocessable_account", date: e.transaction.txn_date, qb_id: e.transaction.qb_id)
                    when NegativeBalanceError
                      t("quickbooks.negative_balance", amt: e.prev_balance)
                    end
          Accounting::SyncIssue.create!(level: :error, loan: @loan, accounting_transaction: e.transaction, message: message)
          return message unless @in_background_job
        rescue Accounting::QB::IntuitRequestError => e
          txn = e.transaction
          is_matching_error = e.message.include?("matched to a downloaded transaction")
          intuit_error_type = is_matching_error ? :matched_transaction : :unknown_intuit_request_exception
          changes_hash = {txn_changes: txn.previous_changes,
                          line_item_changes: txn.line_items.map { |li| li.previous_changes }}
          Rails.logger.error("Accounting::QB::IntuitRequestError #{intuit_error_type} #{e.message}. Txn date: #{txn.txn_date}. Txn qb id: #{txn.qb_id}. Changes: #{changes_hash}")
          ExceptionNotifier.notify_exception(e)
          Accounting::SyncIssue.create!(loan: txn.loan,
                                        accounting_transaction: txn,
                                        message: intuit_error_type,
                                        level: :warning, # want to still see ledger
                                        custom_data: {date: txn.txn_date, qb_id: txn.qb_id})
          # if in bg job, keep going; if in ctrlr
          return I18n.t("quickbooks.misc", msg: e) unless @in_background_job
        rescue StandardError => e
          Rails.logger.error e
          ExceptionNotifier.notify_exception(e)
          Accounting::SyncIssue.create!(level: :error, loan: loan, message: :system_error_recalc)
          # if in bg job, keep going; if in ctrlr
          return I18n.t("quickbooks.misc", msg: e) unless @in_background_job
        end
      end
    end
  end
end
