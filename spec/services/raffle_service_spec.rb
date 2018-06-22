require 'rails_helper'

describe RaffleService do

  before(:each) do
    @campaign = create(:campaign, status: :pending)
  end

  describe "#call" do
    context "when has more then two members" do
      before(:each) do
        create(:member, campaign: @campaign)
        create(:member, campaign: @campaign)
        create(:member, campaign: @campaign)

        @campaign.reload

        @result = RaffleService.new(@campaign).call
      end

      it "results is a hash" do
        expect(@results.class).to eq(Hash)
      end

      it "all members are in results as a member" do
        result_members = @results.map { |r| r.first }
        expect(result_members.sort).to eq(@campaign.members.sort)
      end

      it "all member are in result as a friend" do
        result_friends = @result.map { |r| r.last }
        expect(result_friends.sort).to eq(@campaign.members.sort)
      end

      it "a member don't get yourself" do
        @result.each do |r|
          expect(r.first).not_to eq(r.last)
        end
      end

      it "a member x don't get a member y that get member x" do
        # Desafio
        #user = @result.select do |member, friend| 
        #  member == @campaign.user
        #end

        #friend = @result.select do |member, friend| do
        #  friend == user.last
        #end

        #expect(user.last).not_to eql(friend.first)

        @result.each do |r|
          expect(r.first).not_to eq(@result[r.last].last)
        end
      end
    end

    context "when don't has more than two members" do
      before(:each) do
        create(:member, campaign: @campaign)
        @campaign.reload
        
        @response = RaffleService.new(@campaign).call
      end

      it "return false" do
        expect(@response).to be false
      end
    end
  end


end