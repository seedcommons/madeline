require 'rails_helper'

shared_examples_for 'base_policy' do |record_type|
  let(:described_record) { create(record_type, division: division) }
  subject { described_class.new(user, described_record) }
  # Note, the base permit/forbid tests will automatically build a policy subject around the
  # record_type's class when testing 'index' actions.
  # All other action tests use the standard 'subject'.
  # If 'record_type' is not defined, then the standard 'subject' will also be used for index tests.
  let(:record_type) { record_type }

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

    forbid_all_but_index
  end

  context 'being an admin of a child division' do
    let(:user) { create(:user, :admin, division: child_division) }

    forbid_all_but_index
  end

  context 'being a member of a different division' do
    let(:user) { create(:user, :member) }

    forbid_all_but_index
  end
end

def permit_all
  permit_actions [:index, :create, :show, :edit, :update, :destroy]
end

def forbid_all
  forbid_actions [:index, :create, :show, :edit, :update, :destroy]
end

def permit_all_but_destroy
  permit_actions [:index, :create, :show, :edit, :update]
  forbid_actions [:destroy]
end

def forbid_all_but_index
  forbid_actions [:create, :show, :edit, :update, :destroy]
  permit_actions [:index]
end

def permit_actions(actions)
  actions.each do |action|
    if action == :index && defined?(record_type)
      it 'can index' do
        expect(index_subject(record_type).index?).to be_truthy
      end
    else
      it { should permit_action action }
    end
  end
end

def forbid_actions(actions)
  actions.each do |action|
    if action == :index && defined?(record_type)
      it 'can not index' do
        expect(index_subject(record_type).index?).to be_falsey
      end
    else
      it { should forbid_action action }
    end
  end
end

# Builds a policy instance around the provided record_type's class. To be used when testing
# 'index' actions.
def index_subject(record_type)
  described_class.new(user, record_class(record_type))
end
