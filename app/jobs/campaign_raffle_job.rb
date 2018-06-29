class CampaignRaffleJob < ApplicationJob
  queue_as :emails

  def perform(campaign)
    results = RaffleService.new(campaign).call

    # Send mail to owner of campaign (desafio)
    if results == false
      CampaignMailer.error(campaign).deliver_now
    else
      campaign.members.each(&:set_pixel) # { |m| m.set_pixel }

      results.each do |r|
        CampaignMailer.raffle(campaign, r.first, r.last).deliver_now
      end

      campaign.update(status: :finished)
    end
  end
end
