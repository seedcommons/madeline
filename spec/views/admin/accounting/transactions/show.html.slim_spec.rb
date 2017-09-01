require 'rails_helper'

describe 'admin/accounting/transactions/show.html.slim', type: :view do
  let(:user) { create_admin(root_division) }
  let(:loan) { create(:loan) }
  let!(:transaction) { create(:accounting_transaction, project: loan) }

  before do
    assign(:transaction, transaction)
  end

  it 'is the correct view page' do
    render
    expect(rendered).to have_content('Type of Transaction')
    expect(rendered).to have_content('Bank Account')
  end
end
