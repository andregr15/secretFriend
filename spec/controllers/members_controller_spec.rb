require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env['HTTP_ACCEPT'] = 'application/json'

    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = create(:user)
    @campaign = create(:campaign, user: @current_user)
    sign_in @current_user
  end

  describe "POST #create" do
    context "User exist and own the campaign" do
      before(:each) do
        @member = attributes_for(:member, campaign_id: @campaign.id)
        post :create, params: { member: @member}
      end

      it "Return success" do
        expect(response).to have_http_status(:success)
      end

      it "Create member with right attributes" do
        expect(Member.last.name).to eql(@member[:name])
        expect(Member.last.email).to eql(@member[:email])
        expect(Member.last.campaign.id).to eql(@member[:campaign_id])
      end
    end

    context "User isn't the owner of the campaign" do
      it "returns http forbidden" do
        new_member = attributes_for(:member, campaign_id: create(:campaign, user: create(:user)).id)
        post :create, params: { member: new_member }
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "PUT #update" do
    before(:each) do
      @new_member = attributes_for(:member, campaign: @campaign)
    end

    context "User exists and own the campaign" do
      before(:each) do
        member = create(:member, campaign: @campaign)
        put :update, params: { id: member.id, member: @new_member }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "Member have the new attributes" do
        expect(Member.last.name).to eql(@new_member[:name])
        expect(Member.last.email).to eql(@new_member[:email])
      end
    end

    context "User isn't the owner of the campaign" do
      it "returns http forbidden" do
        member = create(:member)
        put :update, params: { id: member.id, member: member }
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "DELETE #destroy" do
    
    context "User is the owner of the campaign" do
      before(:each) do
        @member = create(:member, campaign: @campaign)
        delete :destroy, params: { id: @member.id }
      end
      
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      #it "database shouldn't have member anymore" do
      #  expect(Member.find(@member.id)).to raise_exception
      #end
    end

    context "User isn't the owner of the campaign" do
      it "returns http forbidden" do
        member = create(:member)
        delete :destroy, params: { id: member.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

end
