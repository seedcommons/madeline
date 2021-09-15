require "rails_helper"

RSpec.describe Accounting::QB::ErrorHandler, type: :model do
  let!(:subject) { Accounting::QB::ErrorHandler.new(loan: loan, in_background_job: in_background_job) }
  let!(:loan) { create(:loan) }
  let!(:txn) { create(:accounting_transaction, project: loan) }
  before do
    allow(ExceptionNotifier).to receive(:notify_exception)
  end

  context "from background job" do
    let!(:in_background_job) { true }

    scenario "no errors and yield block returns a value" do
      expect(subject.handle_qb_errors{ true }).to be nil
    end

    scenario "error an admin user can address" do
      error = Accounting::QB::UnprocessableAccountError.new(loan: loan, transaction: txn )
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(loan.sync_issues.count).to eq 1
      expect(loan.sync_issues.first.message).to include "account"
      expect(ExceptionNotifier).not_to have_received(:notify_exception)
    end

    scenario "unexpected error on one loan an admin user cannot address" do
      error = StandardError
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(loan.sync_issues.count).to eq 1
      expect(loan.sync_issues.first.message).to include "error"
      expect(ExceptionNotifier).to have_received(:notify_exception)
    end

    scenario "unexpected error that means job cannot continue" do
      error =  Quickbooks::ServiceUnavailable
      expect{subject.handle_qb_errors{ raise error }}.to raise_error   Quickbooks::ServiceUnavailable
      expect(Accounting::SyncIssue.count).to eq 1
      expect(Accounting::SyncIssue.first.message).to include "unavailable"
      expect(ExceptionNotifier).to have_received(:notify_exception)
    end
  end

  context "from the transaction UI" do
    let!(:in_background_job) { false }
    scenario "no errors and yield block returns a value" do
      expect(Accounting::QB::ErrorHandler.new(loan: nil, in_background_job: false).handle_qb_errors{ true }).to be nil
    end

    scenario "error with qb connection an admin user can address" do
      error =  Quickbooks::AuthorizationFailure
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(Accounting::SyncIssue.count).to eq 1
      expect(Accounting::SyncIssue.first.message).to include "authorization"
      expect(ExceptionNotifier).not_to have_received(:notify_exception)
    end

    scenario "error with qb connection an admin user cannot address" do
      error =  Quickbooks::ServiceUnavailable
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(Accounting::SyncIssue.count).to eq 1
      expect(Accounting::SyncIssue.first.message).to include "unavailable"
      expect(ExceptionNotifier).to have_received(:notify_exception)
    end

    scenario "error on a loan an admin user can address" do
      error = Accounting::QB::UnprocessableAccountError.new(loan: loan, transaction: txn )
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(loan.sync_issues.count).to eq 1
      expect(loan.sync_issues.first.message).to include "account"
      expect(ExceptionNotifier).not_to have_received(:notify_exception)
    end

    scenario "unexpected error on a loan an admin user cannot address" do
      error =  StandardError
      expect{subject.handle_qb_errors{ raise error }}.not_to raise_error
      expect(Accounting::SyncIssue.count).to eq 1
      expect(Accounting::SyncIssue.first.message).to include "error"
      expect(ExceptionNotifier).to have_received(:notify_exception)
    end
  end
end
