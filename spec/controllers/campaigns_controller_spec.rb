require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe CampaignsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = create(:user)
    sign_in @current_user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    context "campaign exists" do

      context "User is the owner of the campaign" do
        it "Returns success" do
          campaign = create(:campaign, user: @current_user)
          get :show, params: { id: campaign.id }

          expect(response).to have_http_status(:success)
        end
      end

      context "User is not the owner of the campaign" do
        it "Redirects to root" do
          campaign = create(:campaign)
          get :show, params: { id: campaign.id }

          expect(response).to redirect_to('/')
        end
      end

      context "Campaign don't exists" do
        it "Redirects to root" do
          get :show, params: { id: 0 }

          expect(response).to redirect_to('/')
        end
      end
    end

  end

  describe "POST #create" do
    before(:each) do
      @campaign_attributes = attributes_for(:campaign, user: @current_user)
      post :create, params: { campaign: @campaign_attributes }
    end

    it "Redirect to new campaign" do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/campaigns/#{Campaign.last.id}")
    end

    it "Create campaign with right attributes" do
      expect(Campaign.last.user).to eql(@current_user)
      expect(Campaign.last.title).to eql("Nova Campanha")
      expect(Campaign.last.description).to eql("Descreva sua campanha...")
      expect(Campaign.last.status).to eql('pending')
    end

    it "Create campaign with owner assosiated as a member" do
      expect(Campaign.last.members.last.name).to eql(@current_user.name)
      expect(Campaign.last.members.last.email).to eql(@current_user.email)
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "User is the Campaign Owner" do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        delete :destroy, params: { id: campaign.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "database shouldn't have campaign anymore" do
        expect(Campaign.last).to be_nil
      end
    end

    context "User isn't the Campaign Owner" do
      it "returns http forbidden" do
        campaign = create(:campaign)
        delete :destroy, params: { id: campaign.id }
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "PUT #update" do
    before(:each) do
      @new_campaign_attributes = attributes_for(:campaign)
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "User is the Campaign Owner" do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "Campaign have the new attributes" do
        expect(Campaign.last.title).to eql(@new_campaign_attributes[:title])
        expect(Campaign.last.description).to eql(@new_campaign_attributes[:description])
      end
    end

    context "User isn't the Campaign Owner" do
      it "returns http forbidden" do
        campaign = create(:campaign)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

  describe "GET #raffle" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    context "User is the Campaign Owner" do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end

      context "Has more than two members" do
        before(:each) do
          @member1 = create(:member, campaign: @campaign)
          @member2 = create(:member, campaign: @campaign)
          @member3 = create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it 'job is created' do
          ActiveJob::Base.queue_adapter = :test
            expect{
              CampaignRaffleJob.perform_later @campaign
            }.to have_enqueued_job.on_queue('emails')
        end

        it 'should have sended the e-mails' do
          expect {
            perform_enqueued_jobs do
              CampaignRaffleJob.perform_later @campaign
            end
          }.to change { ActionMailer::Base.deliveries.size }.by(4)
        end

        it 'should have sended the e-mails to the right members' do
          perform_enqueued_jobs do
            CampaignRaffleJob.perform_later @campaign
          end

          mails = ActionMailer::Base.deliveries
          expect(mails.any? { |m| m.to[0] == @current_user.email }).to be true
          expect(mails.any? { |m| m.to[0] == @member1.email }).to be true
          expect(mails.any? { |m| m.to[0] == @member2.email }).to be true
          expect(mails.any? { |m| m.to[0] == @member3.email }).to be true
        end
      end

      context "No more than two members" do
        before(:each) do
          create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
        end

        it "returns http success" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "User isn't the Campaign Owner" do
      before(:each) do
        @campaign = create(:campaign)
        post :raffle, params: { id: @campaign.id }
      end

      it "returns  http forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end

  end

end