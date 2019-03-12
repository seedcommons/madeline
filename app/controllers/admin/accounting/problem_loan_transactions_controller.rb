module Admin
  module Accounting
    class ProblemLoanTransactionsController < Admin::AdminController
      def index
        authorize :'accounting/problem_loan_transaction', :index?
        if params[:loan_id]
          txn_ids = ::Accounting::ProblemLoanTransaction.where(project_id: params[:loan_id]).map(&:accounting_transaction_id)
          @plts = ::Accounting::ProblemLoanTransaction.where(accounting_transaction_id: txn_ids).group_by(&:txn_id)
        else
          @plts = ::Accounting::ProblemLoanTransaction.all.group_by(&:txn_id)
        end
      end

      def show
        authorize :'accounting/problem_loan_transaction', :show?
        @plt = ::Accounting::ProblemLoanTransaction.find(params[:id])
      end
    end
  end
end
