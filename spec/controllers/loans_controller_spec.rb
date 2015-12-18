require 'rails_helper'

describe LoansController do
  before { pending 're-implement in new project' }
  describe "GET #index" do
    let(:loans) { create_list(:loan, 5, :active) }
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    context 'with loan' do
      let(:loan) { create(:loan, :active) }

      it "returns http success" do
        get :show, id: loan, locale: :en
        expect(response).to have_http_status(:success)
      end
    end
  end
end
