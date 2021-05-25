require 'rails_helper'

describe Division, type: :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end

  it 'can only have one root' do
    root_division
    expect { create(:division, parent: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'short name' do

    before { allow(SecureRandom).to receive(:uuid) {'iamauuid2018'} }

    let!(:division_1) { create(:division, name: 'trouble') }
    let!(:division_2) { create(:division, name: 'trouble', notify_on_new_logs: true) }
    let!(:division_3) { create(:division, name: '---') }

    it 'generates a short name if one is not provided' do
      expect(division_1.short_name).to eq('trouble')
    end

    it 'generates a short name for division with the same name' do
      expect(division_2.short_name).to eq('trouble-iamauuid2018')
    end

    it 'generates short name for division with just hyphens' do
      expect(division_3.short_name).to eq('-iamauuid2018')
    end
  end

  describe '#qb_division' do
    subject { division.qb_division }

    context 'for root division' do
      let(:division) { root_division }

      context 'with no qb connection' do
        it { is_expected.to be_nil }
      end

      context 'with connection on root division' do
        let!(:connection) { create(:accounting_qb_connection, division: division) }
        it { is_expected.to eq(division) }
      end
    end

    context 'for descendant division' do
      let(:parent) { create(:division, parent: root_division) }
      let(:division) { create(:division, parent: parent) }

      context 'with no qb connection' do
        it { is_expected.to be_nil }
      end

      context 'with connection on self' do
        let!(:connection) { create(:accounting_qb_connection, division: division) }
        it { is_expected.to eq(division) }
      end

      context 'with connection on parent division' do
        let!(:connection) { create(:accounting_qb_connection, division: parent) }
        it { is_expected.to eq(parent) }
      end

      context 'with connection on root division' do
        let!(:connection) { create(:accounting_qb_connection, division: root_division) }
        it { is_expected.to eq(root_division) }
      end
    end
  end
end
