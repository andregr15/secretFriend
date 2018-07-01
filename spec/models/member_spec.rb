require 'rails_helper'

RSpec.describe Member, type: :model do
  describe 'set_pixel' do
    it 'should have generated member token' do
      member = create(:member)
      member.set_pixel
      expect(Member.last.token).to eql(member.token)
    end
  end
end
