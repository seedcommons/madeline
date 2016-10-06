module LoansHelper
  # This should be updated whenever columns are added/removed to the timeline table
  def timeline_table_step_column_count
    5
  end

  def back_to_loans
    session[:loans_path] || loans_path
  end
end
