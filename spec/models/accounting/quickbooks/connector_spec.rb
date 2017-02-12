require 'rails_helper'

RSpec.describe Accounting::Quickbooks::Connector, type: :model do
  let(:valid_token) { 'lvprdxMSsckHORgjp9RCmVaF6anST6VWIVU84eQempNRZy0f' }
  let(:invalid_token) { '' }
  let(:valid_secret) { '295VilDqvyRaUTMFOIzYjUL1eFJCApCwBRItPeWf' }
  let(:invalid_secret) { '' }
  let(:valid_realm_id) { '193514472376479' }
  let(:invalid_realm_id) { '' }

  shared_examples_for 'no token is present' do
    it 'should not be connected' do
      expect(connector.connected?).to be_falsey
    end
    it 'should not be renewable' do
      expect(connector.renewable?).to be_falsey
    end
    it 'should not be expired' do
      expect(connector.expired?).to be_falsey
    end
  end

  context 'with new token' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc })
    end

    it 'should be connected' do
      expect(connector.connected?).to be_truthy
    end
    it 'should not be renewable' do
      expect(connector.renewable?).to be_falsey
    end
    it 'should not be expired' do
      expect(connector.expired?).to be_falsey
    end
  end

  context 'with expiring token' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 20.days.from_now.utc })
    end

    it 'should be connected' do
      expect(connector.connected?).to be_truthy
    end
    it 'should be renewable' do
      expect(connector.renewable?).to be_truthy
    end
    it 'should not be expired' do
      expect(connector.expired?).to be_falsey
    end
  end

  context 'with expired token' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: valid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 2.days.ago.utc })
    end
    it 'should not be connected' do
      expect(connector.connected?).to be_falsey
    end
    it 'should not be renewable' do
      expect(connector.renewable?).to be_falsey
    end
    it 'should be expired' do
      expect(connector.expired?).to be_truthy
    end
  end

  context 'without token' do
    subject(:connector) { Accounting::Quickbooks::Connector.new }

    it_behaves_like 'no token is present'
  end

  context 'with invalid token' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: invalid_token, secret: valid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc })
    end

    it_behaves_like 'no token is present'
  end

  context 'with invalid secret' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: valid_token, secret: invalid_secret, realm_id: valid_realm_id, token_expires_at: 180.days.from_now.utc })
    end

    it_behaves_like 'no token is present'
  end

  context 'with invalid realm id' do
    subject(:connector) do
      Accounting::Quickbooks::Connector.new(quickbooks: { token: valid_token, secret: valid_secret, realm_id: invalid_realm_id, token_expires_at: 180.days.from_now.utc })
    end

    it_behaves_like 'no token is present'
  end
end
