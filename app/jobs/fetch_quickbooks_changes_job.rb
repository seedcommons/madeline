class FetchQuickbooksChangesJob < QuickbooksUpdateJob
  protected

  def loans
    @loans ||= divisions.map do |division|
      division.loans.changed_since(updater.qb_connection.last_updated_at)
    end.flatten.compact
  end
end
