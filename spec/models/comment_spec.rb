require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '.with_user scope' do
    it 'should include user' do
      expect(Comment).to receive(:eager_load).once
      Comment.with_user
    end
  end
end
