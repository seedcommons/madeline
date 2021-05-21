class UpdateAllLoansJob < QuickbooksUpdateJob
  protected

  def loans
    @loans ||= divisions.map(&:loans).flatten.compact
  end
end
