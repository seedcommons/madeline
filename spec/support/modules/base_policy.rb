require 'rails_helper'

shared_examples_for 'base_policy' do |record_class|
  let(:described_record) { create(record_class, division: division) }
  subject { described_class.new(user, described_record) }

  let!(:division) { create(:division) }

  context 'being a member of the division' do
    let(:user) { create(:user, :member, division: division) }

    it { should permit_action :create }
    it { should permit_action :show }
    it { should permit_action :edit }
    it { should permit_action :update }
    it { should forbid_action :destroy }
  end

  context 'being an admin of the division' do
    let(:user) { create(:user, :admin, division: division) }

    it { should permit_action :create }
    it { should permit_action :show }
    it { should permit_action :edit }
    it { should permit_action :update }
    it { should permit_action :destroy }
  end

  context 'being a user of a different division' do
    let(:user) { create(:user, :member) }

    it { should forbid_action :create }
    it { should forbid_action :show }
    it { should forbid_action :edit }
    it { should forbid_action :update }
    it { should forbid_action :destroy }
  end
end
