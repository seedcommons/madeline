require "rails_helper"

describe DocumentationPolicy do
  subject { DocumentationPolicy.new(user, documentation) }
  let(:documentation) { build(:documentation) }

  context "with admin user" do
    let(:user) { create(:user, :admin) }

    permit_all
  end

  context "with member user" do
    let(:user) { create(:user, :member) }

    permit_actions [:show]
    forbid_actions [:create, :edit, :update, :new]
  end
end
