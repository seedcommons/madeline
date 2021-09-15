require "rails_helper"

RSpec.describe Accounting::QB::ErrorHandler, type: :model do
  context "background job" do
    scenario "no errors" do
      expect(Accounting::QB::ErrorHandler.new(loan: nil, in_background_job: true).handle_qb_errors{ true }).to be nil
    end
  end

  context "controller" do
    scenario "no errors" do
      expect(Accounting::QB::ErrorHandler.new(loan: nil, in_background_job: false).handle_qb_errors{ true }).to be nil
    end
  end
end
