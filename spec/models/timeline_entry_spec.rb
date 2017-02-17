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
