require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  context 'with the authenticated user' do
    before :each do
      sign_in FactoryGirl.create :user
    end

    describe 'POST create' do
      it 'does not create comment with empty body' do
        new_post = FactoryGirl.create :post
        post :create, post_id: new_post.id, comment: {comment: ''}, format: :json
        expect(response.content_type).to eq 'application/json'
        expect(response.code).to eq '400'
      end

      it 'should create new comment with filled body' do
        new_post = FactoryGirl.create :post
        expect(new_post.comments.count).to be_zero
        post :create, post_id: new_post.id, comment: {comment: Faker::Lorem.sentence}, format: :json
        expect(response.content_type).to eq 'application/json'
        expect(response.code).to eq '200'
        expect(new_post.comments.count).to eq 1
        expect(new_post.comments.last.user_id).to eq subject.current_user.id
      end
    end

    describe 'PUT update' do
      it 'does not works with old comment' do
        new_post = FactoryGirl.create :post_with_comments, comments_count: 1
        fc = new_post.comments.first
        fc.update! created_at: 5.hours.ago, user_id: subject.current_user.id
        put :update, id: fc.id, post_id: new_post.id, comment: {comment: Faker::Lorem.sentence}, format: :json
        expect(response.content_type).to eq 'application/json'
        expect(response.code).to eq '404'
      end

      it 'should update with the correct fields and reject if empty comment' do
        new_post = FactoryGirl.create :post_with_comments, comments_count: 1
        fc = new_post.comments.first
        fc.update! user_id: subject.current_user.id
        put :update, id: fc.id, post_id: new_post.id, comment: {comment: ''}, format: :json
        expect(response.content_type).to eq 'application/json'
        expect(response.code).to eq '400'
        put :update, id: fc.id, post_id: new_post.id, comment: {comment: Faker::Lorem.sentence}, format: :json
        expect(response.content_type).to eq 'application/json'
        expect(response.code).to eq '200'
      end
    end

    describe 'DELETE destroy' do
      it 'does not works with old comment' do
        new_post = FactoryGirl.create :post_with_comments, comments_count: 1
        fc = new_post.comments.first
        fc.update! created_at: 5.hours.ago, user_id: subject.current_user.id
        delete :destroy, id: fc.id, post_id: new_post.id
        expect(response.code).to eq '404'
      end

      it 'should change state' do
        new_post = FactoryGirl.create :post_with_comments, comments_count: 1
        fc = new_post.comments.first
        fc.update! user_id: subject.current_user.id
        delete :destroy, id: fc.id, post_id: new_post.id
        expect(response).to redirect_to(post_path(new_post.id, anchor: 'comments'))
        expect(fc.reload.deleted?).to be_truthy
      end
    end

    describe 'GET edit' do
      it 'renders edit template' do
        new_post = FactoryGirl.create :post_with_comments, comments_count: 1
        fc = new_post.comments.first
        fc.update! user_id: subject.current_user.id
        get :edit, id: new_post.comments.first, post_id: new_post.id
        expect(response).to render_template('edit')
      end
    end
  end

  context 'with the non-authenticated user' do
    it 'should return 401 code' do
      new_post = FactoryGirl.create :post_with_comments
      post :create, post_id: new_post.id
      expect(response.code).to eq '401'

      put :update, id: new_post.comments.first, post_id: new_post.id
      expect(response.code).to eq '401'

      post :destroy, id: new_post.comments.first, post_id: new_post.id
      expect(response.code).to eq '401'

      get :edit, id: new_post.comments.first, post_id: new_post.id
      expect(response.code).to eq '401'
    end
  end
end
