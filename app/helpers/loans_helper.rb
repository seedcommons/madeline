module LoansHelper
  def back_to_loans
    session[:loans_path] || loans_path
  end
end
