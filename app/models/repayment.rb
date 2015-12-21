class Repayment < ActiveRecord::Base
  include TranslationModule

  belongs_to :loan, :foreign_key => 'LoanID'

  def paid; self.date_paid ? true : false; end

  def status
    if self.paid
      :paid
    elsif self.date_due < Date.today
      :overdue
    else
      :due
    end
  end

  def status_date
    if self.paid
      "#{I18n.t :paid} #{I18n.l self.date_paid, format: :long}"
    else
      "#{I18n.t :due} #{I18n.l self.date_due, format: :long}"
    end
  end

  def amount_formatted
    if self.date_paid
      amount = self.amount_paid
    else
      amount = self.amount_due
    end
    currency_format(amount, self.loan.currency)
  end
end
