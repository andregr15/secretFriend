class PagesController < ApplicationController
  def home
    campaigns = Campaign.find_by(user: current_user)
    redirect_to campaigns_url unless campaigns.nil?
  end
end
