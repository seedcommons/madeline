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

      expect(new_loan.name).to eq "Copy of #{loan.default_name}"
    end
  end

  context 'with non-default name' do
    it 'name column is prepended with "Copy of"' do
      new_loan = duplicator.duplicate

      expect(new_loan.name).to eq "Copy of #{loan.name}"
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
      expect(new_loan.timeline_entries[0].id).not_to eq loan.timeline_entries[0].id
      expect(new_loan.timeline_entries.count).to eq loan.timeline_entries.count
    end

    it 'copies timeline_entry children' do
      root = loan.root_timeline_entry
      new_root = new_loan.root_timeline_entry

      expect(new_root.id).not_to eq root.id
      expect(new_root.c[0].id).not_to eq root.c[0].id
      expect(new_root.c.count).to eq root.c.count

      expect(new_root.c[1].c[0].id).not_to eq root.c[1].c[0].id
      expect(new_root.c[1].c.count).to eq root.c[1].c.count
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
        grandchild = loan.root_timeline_entry.c[0].c[0]
        logs = create_list(:project_log, 2, project_step: grandchild)
        grandchild.project_logs << logs
        loan.save!
      end

      it 'copies project logs' do
        log = loan.project_logs[0]
        new_log = new_loan.project_logs[0]

        expect(new_log.id).not_to eq log.id
        expect(new_log.date).to eq log.date
        expect(new_loan.project_logs.count).to be > 0
        expect(new_loan.project_logs.count).to eq loan.project_logs.count
      end
    end
  end

  context 'with scheduled children' do
    # Creates a timeline and returns nodes stored in a hash.
    let!(:nodes) { ProjectGroupFactoryHelper.create_full_timeline }
    let(:loan) { nodes[:root].project }

    # Break each of the nodes out into a let so that we can examine them individually.
    ProjectGroupFactoryHelper::NODE_NAMES.each do |name|
      let(name) { nodes[name] }
    end

    before do
      # See ProjectGroupFactoryHelper for the layout of nodes in the timeline.
      # We introduce some schedule dependencies in such a way that one of the dependencies
      # actually goes downward instead of upward.
      # g3_s3 is sorted above s1 because g3 has an early step. But we're going to make g3_s3 depend
      # on s1, which won't change the sort order, but is a downward depenendency.
      g3_s3.update_attributes!(schedule_parent_id: s1.id)
      g5_s1.update_attributes!(schedule_parent_id: g3_s3.id)
    end

    shared_examples_for 'scheduled loan' do
      it 'has been properly scheduled' do
        # We need to rebuild these references because we're using these examples for both
        # the old and the new loan.
        root = subject.root_timeline_entry
        s1 = root.c[3]
        g3_s3 = root.c[2].c[2]
        g5_s1 = root.c[5].c[0]

        expect(s1.scheduled_start_date).to eq Date.parse('2017-02-28')
        expect(s1.scheduled_duration_days).to eq 30
        expect(s1.schedule_parent).to be_nil

        expect(g3_s3.scheduled_start_date).to eq Date.parse('2017-03-31')
        expect(g3_s3.scheduled_duration_days).to eq 5
        expect(g3_s3.schedule_parent).to eq s1

        expect(g5_s1.scheduled_start_date).to eq Date.parse('2017-04-06')
        expect(g5_s1.scheduled_duration_days).to eq 3
        expect(g5_s1.schedule_parent).to eq g3_s3
      end
    end

    context 'original loan' do
      subject { loan }
      it_behaves_like 'scheduled loan'
    end

    context 'copied loan' do
      subject { Loan.find(duplicator.duplicate.id) }

      it_behaves_like 'scheduled loan'

      it 'has different loan id from original' do
        expect(subject.id).not_to eq loan.id
      end
    end
  end
end
