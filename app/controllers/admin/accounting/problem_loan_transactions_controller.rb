module Admin
  module Accounting
    class ProblemLoanTransactionsController < Admin::AdminController
      def index
        authorize :'accounting/problem_loan_transaction', :index?
        if params[:loan_id]
          @loan_id = params[:loan_id]
          txn_ids = ::Accounting::ProblemLoanTransaction.where(project_id: @loan_id).map(&:accounting_transaction_id)
          @plts = ::Accounting::ProblemLoanTransaction.where(accounting_transaction_id: txn_ids).group_by(&:txn_id)
        else
          @plts = ::Accounting::ProblemLoanTransaction.all.sort_by(&:project_id).group_by(&:project_id)
          render :index_by_loan
        end
      end

      def show
        @plt = ::Accounting::ProblemLoanTransaction.find(params[:id])
        authorize @plt
      end
    end
  end
end
