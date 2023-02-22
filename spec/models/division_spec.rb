require 'rails_helper'

describe Division, type: :model do
  it 'has a valid factory' do
    expect(create(:division)).to be_valid
  end

  it 'can only have one root' do
    root_division
    expect { create(:division, parent: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'cannot be its own parent' do
    division = create(:division)
    division.parent = division
    expect {division.save! }.to raise_error "Validation failed: Parent Division You cannot add an ancestor as a descendant, Name Division and Parent Division names cannot be the same"
  end

  context 'short name' do
    let(:uuid_1) { 'a123uuid' }
    let(:uuid_2) { 'b123uuid' }
    let(:uuid_3) { 'c123uuid' }
    let(:uuid_4) { 'd123uuid' }

    before {
      allow(SecureRandom).to receive(:uuid).and_return(uuid_1, uuid_2, uuid_3, uuid_4)
      create(:division, name: "preexisting")
    }


    let!(:division_1) { create(:division, name: 'trouble') }
    let!(:division_2) { create(:division, name: 'trouble2', notify_on_new_logs: true) }
    let!(:division_3) { create(:division, name: '---') }

    it 'generates a short name if one is not provided' do
      expect(division_1.short_name).to eq('trouble')
    end

    it 'generates a unique short name if provided short_name on create is a repeat' do
      new_division = create(:division, name: "a new one", short_name: "preexisting")
      expect(new_division.reload.short_name).to include("preexisting-", "uuid")
    end

    it 'generates a unique short name if provided short_name on edit is a repeat' do
      new_division = create(:division, name: "newdiv", short_name: "newdiv")
      new_division.update(short_name: "preexisting")
      expect(new_division.reload.short_name).to include("preexisting", "uuid")
    end

    it 'leaves pre-existing uuid alone when re-saving division' do
      division_1.save!
      expect(division_1.reload.short_name).to eq ('trouble')
    end

    it 'allows manual update of short_name on a division' do
      division_1.short_name = "mytrouble"
      division_1.save!
      expect(division_1.reload.short_name).to eq ('mytrouble')
    end

    it 'generates short name for division with just hyphens' do
      expect(division_3.short_name).to include("uuid")
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

  describe "validation" do
    describe "parent name and own name" do
      let!(:division) { create(:division, name: "Foo") }

      context "when names are different" do
        subject(:division2) { build(:division, name: "Foo2", parent: division) }
        it { is_expected.to be_valid }
      end

      context "when names are same" do
        subject(:division2) { build(:division, name: "Foo", parent: division) }
        it { is_expected.to have_errors(name: "names cannot be the same") }
      end
    end
  end

  describe "self_or_ancestor_of?" do
    let!(:div_a) { create(:division, parent: root_division) }
    let!(:div_b1) { create(:division, parent: div_a) }
    let!(:div_b2) { create(:division, parent: div_a) }
    let!(:div_c) { create(:division, parent: div_b1) }

    it "is correct" do
      expect(div_b1.self_or_ancestor_of?(div_b1)).to be(true)
      expect(div_b1.self_or_ancestor_of?(div_b2)).to be(false)
      expect(root_division.self_or_ancestor_of?(div_b2)).to be(true)
      expect(div_a.self_or_ancestor_of?(div_b2)).to be(true)
      expect(div_a.self_or_ancestor_of?(div_b2)).to be(true)
      expect(div_c.self_or_ancestor_of?(div_b2)).to be(false)
    end
  end

  describe "self_or_descendant_of?" do
    let!(:div_a) { create(:division) }
    let!(:div_b1) { create(:division, parent: div_a) }
    let!(:div_b2) { create(:division, parent: div_a) }
    let!(:div_c1) { create(:division, parent: div_b1) }
    let!(:div_c2) { create(:division, parent: div_b1) }

    it "is correct" do
      expect(div_b1.self_or_descendant_of?(div_b1)).to be(true)
      expect(div_b1.self_or_descendant_of?(div_b2)).to be(false)
      expect(div_a.self_or_descendant_of?(div_b2)).to be(false)
      expect(div_c1.self_or_descendant_of?(div_b1)).to be(true)
      expect(div_c2.self_or_descendant_of?(div_b1)).to be(true)
    end
  end
end
