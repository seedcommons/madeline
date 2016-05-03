require 'rails_helper'

shared_examples_for 'base_policy' do |record_class|
  let(:described_record) { create(record_class, division: division) }
  subject { described_class.new(user, described_record) }

  let!(:parent_division) { create(:division) }
  let!(:division) { create(:division, parent: parent_division) }
  let!(:child_division) { create(:division, parent: division) }

  context 'being a member of a parent division' do
    let(:user) { create(:user, :member, division: parent_division) }

    permit_all_but_destroy
  end

  context 'being an admin of a parent division' do
    let(:user) { create(:user, :admin, division: parent_division) }

    permit_all
  end

  context 'being a member of the division' do
    let(:user) { create(:user, :member, division: division) }

    permit_all_but_destroy
  end

  context 'being an admin of the division' do
    let(:user) { create(:user, :admin, division: division) }

    permit_all
  end

  context 'being a member of a child division' do
    let(:user) { create(:user, :admin, division: child_division) }

    forbid_all
  end

  context 'being an admin of a child division' do
    let(:user) { create(:user, :admin, division: child_division) }

    forbid_all
  end

  context 'being a member of a different division' do
    let(:user) { create(:user, :member) }

    forbid_all
  end
end

# Todo: Confirm business rules and update tests for index permissions.

def permit_all
  permit_actions [:index, :create, :show, :edit, :update, :destroy]
end

def forbid_all
  forbid_actions [:create, :show, :edit, :update, :destroy]
end

def permit_all_but_destroy
  permit_actions [:index, :create, :show, :edit, :update]
  forbid_actions [:destroy]
end

def permit_actions(actions)
  actions.each do |action|
    it { should permit_action action }
  end
end

def forbid_actions(actions)
  actions.each do |action|
    it { should forbid_action action }
  end
end
