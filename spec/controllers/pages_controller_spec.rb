require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe "GET #home" do
    it "returns http success" do
      get :home
      expect(response).to have_http_status(:success)
    end

    context 'should have redirected to /campaigns if current_user has at least one campaign' do
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @current_user = create(:user)
        @campaign = create(:campaign, user: @current_user)
        sign_in @current_user
      end

      it 'returns http sucess' do
        get :home
        expect(response).to have_http_status(302)
      end

      it 'redirects to /campaigns' do
        get :home
        expect(response).to redirect_to('/campaigns')
      end
    end
  end

end
