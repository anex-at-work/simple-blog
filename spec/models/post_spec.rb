require 'rails_helper'

RSpec.describe Post, type: :model do
  context 'creation' do
    it 'should set published_at to now' do
      post = FactoryGirl.build :post
      expect(post.published_at).to be
      expect(post.published_at).to be <= Time.zone.now
    end
  end
end
