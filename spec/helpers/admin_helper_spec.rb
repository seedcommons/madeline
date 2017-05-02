require 'rails_helper'

describe AdminHelper, type: :helper do
  describe "indented_option_label" do
    let(:root) { create(:root_project_group, :with_descendants) }

    it "should return space-padded label text" do
      g1 = root.children.first
      g1_g1 = root.children.first.children.first

      expect(indented_option_label(root, :summary_or_none)).to eq "[None]"
      expect(indented_option_label(g1, :summary_or_none)).to eq g1.summary.to_s
      expect(indented_option_label(g1_g1, :summary_or_none)).to eq "&nbsp; &nbsp; #{CGI::escapeHTML(g1_g1.summary.to_s)}"
    end
  end
end
