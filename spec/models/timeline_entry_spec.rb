require "rails_helper"

describe TimelineEntry do
  describe "max_descendant_depth" do
    let(:root) { create(:root_project_group, :with_descendants) }

    it "should be correct for root" do
      expect(root.max_descendant_depth).to eq 4
    end

    it "should be correct, but not necessarily match root, for interior node" do
      expect(root.children[0].max_descendant_depth).to eq 2
    end
  end
end
