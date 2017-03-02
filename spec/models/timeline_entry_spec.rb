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

require "rails_helper"

describe TimelineEntry do
  let(:root) { create(:root_project_group, :with_descendants) }

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
