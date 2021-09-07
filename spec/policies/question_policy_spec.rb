require "rails_helper"

describe QuestionPolicy do
  let(:division) { create(:division) }
  let(:question) { create(:question, division: division) }
  subject { QuestionPolicy.new(user, question) }

  context "being division admin" do
    let!(:user) { create(:user, :admin, division: division) }
    permit_actions [:index, :show, :edit, :move, :update, :new, :create, :destroy]
  end

  context "being parent division admin" do
    let!(:user) { create(:user, :admin, division: division.parent) }
    permit_actions [:index, :show, :edit, :move, :update, :new, :create, :destroy]
  end

  context "being sibling division admin" do
    let!(:user) { create(:user, :admin, division: create(:division, parent: division.parent)) }
    permit_actions [:index, :show]
    forbid_actions [:edit, :move, :update, :new, :create, :destroy]
  end

  context "being child division admin" do
    let!(:user) { create(:user, :admin, division: create(:division, parent: division)) }
    permit_actions [:index, :show]
    forbid_actions [:edit, :move, :update, :new, :create, :destroy]
  end

  context "being division member" do
    let!(:user) { create(:user, :member, division: division) }
    permit_actions [:index, :show]
    forbid_actions [:edit, :move, :update, :new, :create, :destroy]
  end
end
