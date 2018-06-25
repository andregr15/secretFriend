class CampaignsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_campaign, only: [:show, :destroy, :update, :raffle]
  before_action :is_owner?, only: [:show, :destroy, :update, :raffle]

  def show
  end

  def index
    @campaigns = current_user.campaigns
  end

  def create
    @campaign = Campaign.new(campaign_params)

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to "/campaigns/#{@campaign.id}" }
      else
        format.html { redirect_to main_app.root_url, notice: @campaigns.errors }
      end
    end
  end

  def update
    respond_to do |format|
      if @compaign.update(campaign_params)
        format.json { render json: true }
      else
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @campaign.destroy
    
    respond_to do |format|
      format.json { render json: true }
    end
  end

  def raffle
    respond_to do |format|
      if @campaign.status != "pending"
        format.json { render json: 'Já foi sorteada', status: :unprocessable_entity }
      elsif @campaign.members.count < 3
        format.json { render json: 'A campanha precisa pelo menos 3 pessoas', status: :unprocessable_entity }
      else
        CampaignRaffleJob.perform_later @campaign
        format.json { render json: true }
      end
    end
  end

  private

  def set_campaign
    @campaign = Camapign.find(params[:id])
  end

  def compaign_params
    params.require(:campaign).permit(:title, :description, :event_date, :event_hour, :location).merge(user: current_user)
  end

  def is_owner?
    unless current_user == @campaign.user
      respond_to do |format|
        format.json { render json: false, status: :forbidden }
        format.html { redirect_to main_app.root_url }
        end
      end
    end
  end
end
