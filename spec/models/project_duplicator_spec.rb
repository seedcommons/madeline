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
      create(:loan, :with_loan_media, :with_timeline, :with_accounting_transaction, :with_copies)
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

    it 'copies health_check' do
      expect(new_loan.health_check.loan_id).to eq new_loan.id
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

  context 'with scheduled children' do
    let(:loan) do
      loan = create(:loan)

      root = create(:root_project_group, project: loan)

      s21 = FactoryGirl.create(:project_step, project: loan, division: root.division,
        scheduled_start_date: '2017-01-01', scheduled_duration_days: 5)
      s11 = FactoryGirl.create(:project_step, project: loan, division: root.division, schedule_parent: s21,
        scheduled_duration_days: 7)
      s3 = FactoryGirl.create(:project_step, project: loan, division: root.division, schedule_parent: s11,
        scheduled_duration_days: 2)

      helper = ProjectGroupFactoryHelper
      g1 = helper.add_child_group(root, root)
        g1.children << s11
      g2 = helper.add_child_group(root, root)
        g2.children << s21
      root.children << s3

      loan
    end

    it 'has properly scheduled original loan' do
      # Do some ground truth assertions here to ensure we are copying what we expect.

      children = loan.root_timeline_entry.children
      expect(children.count).to eq 3

      g1 = children[0]
      g2 = children[1]
      s3 = children[2]
      expect(g1.group?).to be_truthy
      expect(g2.group?).to be_truthy
      expect(s3.step?).to be_truthy

      s11 = g1.children[0]
      s21 = g2.children[0]
      expect(s11.step?).to be_truthy
      expect(s21.step?).to be_truthy

      expect(s21.scheduled_start_date).to eq Date.parse('2017-01-01')
      expect(s21.scheduled_duration_days).to eq 5
      expect(s21.schedule_parent).to be_nil

      expect(s11.scheduled_start_date).to eq Date.parse('2017-01-07')
      expect(s11.scheduled_duration_days).to eq 7
      expect(s11.schedule_parent).to eq s21

      expect(s3.scheduled_start_date).to eq Date.parse('2017-01-15')
      expect(s3.scheduled_duration_days).to eq 2
      expect(s3.schedule_parent).to eq s11
    end
  end
end
