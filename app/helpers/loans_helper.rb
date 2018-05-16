module LoansHelper
  def back_to_loans
    session[:loans_path] || public_loans_path
  end
end
