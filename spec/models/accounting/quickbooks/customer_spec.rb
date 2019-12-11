require 'rails_helper'

RSpec.describe Accounting::Quickbooks::CustomerOld, type: :model do
  let(:qb_customer_id) { '91234' }
  let(:qb_new_customer) { instance_double(Quickbooks::Model::Customer, id: qb_customer_id) }
  let(:service) { instance_double(Quickbooks::Service::Customer) }

  subject { described_class.new(organization: organization, qb_connection: nil) }

  before do
    allow(subject).to receive(:service).and_return(service)
  end

  shared_examples_for 'qb customer' do
    context "where qb customer id already in madeline" do
      let(:organization) { create(:organization, qb_id: qb_customer_id) }

      it 'does not create a customer' do
        expect(service).not_to receive(:create)
        subject.reference
      end

      it 'returns proper customer reference' do
        allow(service).to receive(:create).and_return(qb_new_customer)

        reference = subject.reference
        expect(reference.type).to eq 'Customer'
        expect(reference.entity_ref.value).to eq qb_customer_id
      end
    end

    context "where qb customer id not in madeline" do
      let(:organization) { create(:organization, name: customer_name) }
      before do
        expect(service).to receive(:find_by).and_return(qb_query_result)
      end

      context "and qb customer is not in qb either" do
        let(:qb_query_result) { double(entries: []) }

        context "and creating customer with this name succeeds" do
          before do
            expect(service).to receive(:create) do |arg|
              expect(arg.display_name).to eq created_customer_name
            end.and_return(qb_new_customer)
          end

          it "saves info in madeline" do
            reference = subject.reference
            expect(reference.type).to eq 'Customer'
            expect(reference.entity_ref.value).to eq qb_customer_id
            expect(Organization.where(qb_id: qb_customer_id).count).to eq 1
          end
        end

        context "and creating customer with this name fails with duplicate name error" do
          before do
            @times_called = 0
            expect(service).to receive(:create).twice do
              @times_called += 1
              if @times_called == 1
                raise(::Quickbooks::IntuitRequestException, 'Duplicate Name Exists Error')
              else
                qb_new_customer
              end
            end
          end

          it "creates customer with modified name and saves info in madeline" do
            reference = subject.reference
            expect(reference.type).to eq 'Customer'
            expect(reference.entity_ref.value).to eq qb_customer_id
            expect(Organization.where(qb_id: qb_customer_id).count).to eq 1
          end
        end
      end

      context "where qb customer is in qb already" do
        let(:qb_customer_result) { double(id: qb_customer_id) }
        let(:qb_query_result) { double(entries: [qb_customer_result]) }

        it "saves customer info in madeline" do
          reference = subject.reference
          expect(reference.type).to eq 'Customer'
          expect(reference.entity_ref.value).to eq qb_customer_id
          expect(Organization.where(qb_id: qb_customer_id).count).to eq 1
        end
      end
    end
  end

  context 'with valid name' do
    let(:customer_name) { 'A cooperative with a name' }
    let(:created_customer_name) { customer_name }

    it_behaves_like 'qb customer'
  end

  context 'with invalid name' do
    let(:customer_name) { 'A name:with a colon' }
    let(:created_customer_name) { 'A name_with a colon' }

    it_behaves_like 'qb customer'
  end
end
