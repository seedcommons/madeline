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

    # root_timeline_entry children are incorrect on new_loan. Reload it, to bust the cache.
    # Using #reload does not do it.
    let(:new_loan) { Loan.find(duplicator.duplicate.id) }

    it 'ignores media' do
      expect(new_loan.media.count).to eq 0
    end

    it 'copies timeline_entries' do
      expect(new_loan.timeline_entries.first.id).not_to eq loan.timeline_entries.first.id
      expect(new_loan.timeline_entries.count).to eq loan.timeline_entries.count
    end

    it 'copies timeline_entry children' do
      root = loan.root_timeline_entry
      new_root = new_loan.root_timeline_entry

      expect(new_root.id).not_to eq root.id
      expect(new_root.children.first.id).not_to eq root.children.first.id
      expect(new_root.children.count).to eq root.children.count

      expect(new_root.children[1].children[0].id).not_to eq root.children[1].children[0].id
      expect(new_root.children[1].children.count).to eq root.children[1].children.count
    end

    it 'copies loan_health_check' do
      expect(new_loan.loan_health_check.loan_id).to eq new_loan.id
    end

    it 'ignores transactions' do
      expect(new_loan.transactions.count).to eq 0
    end

    it 'ignores copies' do
      expect(new_loan.copies.count).to eq 0
    end

    context 'with project logs' do
      before do
        grandchild = loan.root_timeline_entry.children[0].children[0]
        logs = create_list(:project_log, 2, project_step: grandchild)
        grandchild.project_logs << logs
        loan.save!
      end

      it 'copies project logs' do
        log = loan.project_logs.first
        new_log = new_loan.project_logs.first

        expect(new_log.id).not_to eq log.id
        expect(new_log.date).to eq log.date
        expect(new_loan.project_logs.count).to be > 0
        expect(new_loan.project_logs.count).to eq loan.project_logs.count
      end
    end
  end
end
