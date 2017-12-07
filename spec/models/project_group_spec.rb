# == Schema Information
#
# Table name: timeline_entries
#
#  actual_end_date         :date
#  agent_id                :integer
#  created_at              :datetime         not null
#  date_change_count       :integer          default(0), not null
#  finalized_at            :datetime
#  id                      :integer          not null, primary key
#  is_finalized            :boolean
#  old_duration_days       :integer          default(0)
#  old_start_date          :date
#  parent_id               :integer
#  project_id              :integer
#  schedule_parent_id      :integer
#  scheduled_duration_days :integer          default(0)
#  scheduled_start_date    :date
#  step_type_value         :string
#  type                    :string           not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_timeline_entries_on_agent_id    (agent_id)
#  index_timeline_entries_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_8589af42f8  (agent_id => people.id)
#  fk_rails_af8b359300  (project_id => projects.id)
#  fk_rails_d21c3b610d  (parent_id => timeline_entries.id)
#  fk_rails_fe366670d0  (schedule_parent_id => timeline_entries.id)
#

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

  context 'changing parent' do
    let(:root) { create(:root_project_group) }
    let(:group) { create(:project_group) }
    let(:child1) { create(:project_group, parent: root) }
    let(:child2) { create(:project_group, parent: root) }

    it "should disallow changing the root group's parent" do
      expect { root.update(parent: group) }.to raise_error(ArgumentError)
    end

    it 'should disallow changing the parent of a regular group to nil' do
      expect { child1.update(parent: nil) }.to raise_error(ArgumentError)
    end

    it 'should allow the parent to be changed otherwise' do
      expect(child1.update(parent: child2)).to be true
    end
  end

  context "with descendants" do
    # Creates a timeline and returns nodes stored in a hash.
    let!(:nodes) { ProjectGroupFactoryHelper.create_full_timeline }

    # Break each of the nodes out into a let so that we can examine them individually.
    ProjectGroupFactoryHelper::NODE_NAMES.each do |name|
      let(name) { nodes[name] }
    end

    describe "descendant_leaf_count" do
      it "should be correct for root" do
        expect(root.descendant_leaf_count).to eq(
          # There is one childless group that should be counted in addition to all the steps.
          root.project.timeline_entries.where(type: "ProjectStep").count + 1)
      end

      it "should be correct for interior node" do
        group = root.filtered_children[1]
        expect(group.descendant_leaf_count).to eq 2
      end
    end

    describe "max_descendant_group_depth" do
      it "should be correct for root" do
        expect(root.max_descendant_group_depth).to eq 2
      end

      it "should be correct, but not necessarily match root, for interior node" do
        expect(root.filtered_children[2].max_descendant_group_depth).to eq 1
      end
    end

    describe "filtered_children" do
      it "should be sorted" do
        expect(root.filtered_children).to eq [g1, g2, g3, s1, g4, g5, g6, s2]
        expect(g2.filtered_children).to eq [g2_g1, g2_g2]
        expect(g3.filtered_children).to eq [g3_s1, g3_s2, g3_s3, g3_s4]
      end
    end

    describe "self_and_descendant_groups_preordered" do
      it "should return flat pre-ordered array of groups" do
        expect(root.self_and_descendant_groups_preordered).to eq(
          [root, g1, g2, g2_g1, g2_g2, g3, g4, g5, g6])
      end
    end
  end
end
