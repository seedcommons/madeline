# == Schema Information
#
# Table name: accounting_qb_connections
#
#  id               :integer          not null, primary key
#  access_token     :string           not null
#  invalid_grant    :boolean          default(FALSE), not null
#  last_updated_at  :datetime         not null
#  refresh_token    :string           not null
#  token_expires_at :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  division_id      :integer          not null
#  realm_id         :string           not null
#
# Indexes
#
#  index_accounting_qb_connections_on_division_id  (division_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#

require 'rails_helper'

# TODO: Figure out if it's possible to make these tests work
# there's no way to guarantee valid tokens hardcoded like this
xdescribe Accounting::QB::Connection, type: :model do
  let(:valid_token) { 'lvprdxMSsckHORgjp9RCmVaF6anST6VWIVU84eQempNRZy0f' }
  let(:invalid_token) { '' }
  let(:valid_secret) { '295VilDqvyRaUTMFOIzYjUL1eFJCApCwBRItPeWf' }
  let(:invalid_secret) { '' }
  let(:valid_realm_id) { '193514472376479' }
  let(:invalid_realm_id) { '' }

  shared_examples_for 'no token is present' do
    it 'should not be connected' do
      expect(connection.connected?).to be_falsey
    end
    it 'should not be renewable' do
      expect(connection.renewable?).to be_falsey
    end
    it 'should not be expired' do
      expect(connection.expired?).to be_falsey
    end
  end

  context 'with new token' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc)
    end

    it 'should be connected' do
      expect(connection.connected?).to be_truthy
    end
    it 'should not be renewable' do
      expect(connection.renewable?).to be_falsey
    end
    it 'should not be expired' do
      expect(connection.expired?).to be_falsey
    end
  end

  context 'with expiring token' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 20.days.from_now.utc)
    end

    it 'should be connected' do
      expect(connection.connected?).to be_truthy
    end
    it 'should be renewable' do
      expect(connection.renewable?).to be_truthy
    end
    it 'should not be expired' do
      expect(connection.expired?).to be_falsey
    end
  end

  context 'with expired token' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 2.days.ago.utc)
    end
    it 'should not be connected' do
      expect(connection.connected?).to be_falsey
    end
    it 'should not be renewable' do
      expect(connection.renewable?).to be_falsey
    end
    it 'should be expired' do
      expect(connection.expired?).to be_truthy
    end
  end

  context 'without token' do
    subject(:connection) { Accounting::QB::Connection.new }

    it_behaves_like 'no token is present'
  end

  context 'with invalid token' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: invalid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc)
    end

    it_behaves_like 'no token is present'
  end

  context 'with invalid secret' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: valid_token, secret: invalid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc)
    end

    it_behaves_like 'no token is present'
  end

  context 'with invalid realm id' do
    subject(:connection) do
      Accounting::QB::Connection.new(token: valid_token, secret: valid_secret, realm_id: invalid_realm_id, token_expires_at: 180.days.from_now.utc)
    end

    it_behaves_like 'no token is present'
  end
end
