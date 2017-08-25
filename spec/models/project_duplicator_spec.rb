require 'rails_helper'

RSpec.describe ProjectDuplicator, type: :model do
  subject(:duplicator) { described_class.new(loan) }
  let(:loan) { create(:loan) }

  it 'copies proper columns' do
    new_loan = duplicator.duplicate

    attribs_to_exclude = %w(id created_at updated_at name original_id)
    expect(new_loan.attributes.except(*attribs_to_exclude))
      .to eq loan.attributes.except(*attribs_to_exclude)
  end

  context 'with default name' do
    let(:loan) { create(:loan, name: '') }

    it 'name column is prepended with "Copy of"' do
      new_loan = duplicator.duplicate

      expect(new_loan.name) .to eq "Copy of #{loan.default_name}"
    end
  end

  context 'with non-default name' do
    it 'name column is prepended with "Copy of"' do
      new_loan = duplicator.duplicate

      expect(new_loan.name) .to eq "Copy of #{loan.name}"
    end
  end

  context 'with populated associations' do
    let(:loan) do
      create(:loan, :with_loan_media, :with_timeline, :with_accounting_transaction,
        :with_copies)
    end
    let(:new_loan) { duplicator.duplicate }

    it 'ignores media' do
      expect(new_loan.media.count).to eq 0
    end

    it 'ignores timeline_entries' do
      expect(new_loan.timeline_entries.count).to eq 0
    end

    it 'ignores loan_health_check' do
      expect(new_loan.loan_health_check).to be_nil
    end

    it 'ignores transactions' do
      expect(new_loan.transactions.count).to eq 0
    end

    it 'ignores copies' do
      expect(new_loan.copies.count).to eq 0
    end
  end
end
