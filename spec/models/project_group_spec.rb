require 'rails_helper'

describe ProjectGroup, type: :model do
  it 'has a valid factory' do
    expect(create(:project_group)).to be_valid
  end

  context 'without children' do
    subject(:group) { create(:project_group) }

    let(:step) { create(:project_step) }

    it 'can be destroyed' do
      group.destroy

      expect(group.destroyed?).to be_truthy
    end

    it 'can have child steps' do
      group.add_child(step)

      expect(group.children.count).to eq 1
      expect(group.children.first).to eq step
    end
  end

  context 'with children' do
    let(:child_one) { create(:project_step) }
    let(:child_two) { create(:project_step) }

    subject(:group) do
      group = create(:project_group)
      group.add_child(child_one)
      group.add_child(child_two)

      group
    end

    it 'can not be destroyed' do
      expect { group.destroy }.to raise_error ProjectGroup::DestroyWithChildrenError
    end
  end

  context "with descendants" do
    let(:root) { create(:root_project_group, :with_descendants) }

    describe "descendant_leaf_count" do
      it "should be correct for root" do
        expect(root.descendant_leaf_count).to eq(
          # There is one childless group that should be counted in addition to all the steps.
          root.project.timeline_entries.where(type: "ProjectStep").count + 1)
      end

      it "should be correct for interior node" do
        group = root.children[0]
        expect(group.descendant_leaf_count).to eq group.children.size
      end
    end

    describe "max_descendant_group_depth" do
      it "should be correct for root" do
        expect(root.max_descendant_group_depth).to eq 3
      end

      it "should be correct, but not necessarily match root, for interior node" do
        expect(root.children[0].max_descendant_group_depth).to eq 1
      end
    end

    describe "filtered_children" do
      it "should be sorted" do
        root.children.select(&:group?).each do |group|
          # Groups should be first
          groups = group.children.select(&:group?)
          expect(group.filtered_children[0...groups.size]).to eq groups

          # Dates should be in order
          dates = group.children.map(&:scheduled_start_date).compact
          filtered_dates = group.filtered_children.map(&:scheduled_start_date).compact
          expect(filtered_dates).to eq dates.sort
        end
      end
    end
  end
end
