require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end

    it 'renders the index template when shown for user' do
      user = FactoryGirl.create :user
      get :index, user_id: user.id
      expect(response).to render_template('index')
    end

    it 'render the index template when shown for tags' do
      get :index, tag_id: Faker::Lorem.word
      expect(response).to render_template('index')
    end
  end

  describe 'GET show' do
    it 'renders the show template to exist post' do
      post = FactoryGirl.create :post, user: FactoryGirl.create(:user)
      get :show, id: post.id
      expect(response).to render_template('show')
      expect(assigns(:comments)).to be
    end

    it 'should return 404 for non-exist post' do
      get :show, id: 404 # just number, not a magic-number
      expect(response.code).to eq "404"
    end
  end

  context 'with the authenticated user' do
    before :each do
      sign_in FactoryGirl.create(:user_with_posts)
    end

    describe 'GET new' do
      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
      end

      it 'should assign @post' do
        get :new
        expect(assigns(:post)).to be_a_new(Post)
      end
    end

    describe 'POST create' do
      it 'should redirect if wrong parameters' do
        normal_post = FactoryGirl.build :post

        expect{post(:create)}.to raise_error ActionController::ParameterMissing

        post :create, {post: {name: normal_post.name}} # content not defined
        expect(response).to render_template(:new)

        post :create, {post: {content: normal_post.content}} # content not defined
        expect(response).to render_template(:new)
      end

      it 'creates and redirects when all OK' do
        normal_post = FactoryGirl.build :post
        post :create, {post: {name: normal_post.name, content: normal_post.content}} # content not defined
        expect(response).to redirect_to(action: :index)
        post_created = Post.order(:created_at).last
        expect(post_created).to be
        expect(post_created.published_at).to be <= Time.zone.now
        expect(post_created.name).to eq normal_post.name
        expect(post_created.content).to eq normal_post.content
        expect(post_created.user_id).to eq subject.current_user.id
      end
    end

    describe 'GET tags' do
      it 'renders json with query' do
        query = Faker::Lorem.word
        get :tags, {q: query, format: :json}
        expect(response.content_type).to eq 'application/json'
        expect(JSON.parse(response.body)['total_count']).to eq 1
        expect(JSON.parse(response.body)['items']).to contain_exactly({'id' => query, 'name' => query})
      end
    end

    describe 'GET edit' do
      it 'renders the edit template with assigned post' do
        get :edit, id: subject.current_user.posts.first
        expect(response).to render_template('edit')
        expect(assigns(:post)).to eq subject.current_user.posts.first
      end
    end

    describe 'PUT update' do
      it 'renders edit template with broken params' do
        put :update, id: subject.current_user.posts.first, post: {name: ''}
        expect(response).to render_template('edit')

        put :update, id: subject.current_user.posts.first, post: {content: ''}
        expect(response).to render_template('edit')
      end

      it 'should save and redirect to index when all OK' do
        new_name = Faker::Lorem.sentence
        new_content = Faker::Lorem.paragraph
        fp = subject.current_user.posts.first
        put :update, id: fp, post: {name: new_name,
          content: new_content, status: :unpublished}
        fp.reload
        expect(response).to redirect_to(action: :index)
        expect(fp.name).to eq new_name
        expect(fp.content).to eq new_content
        expect(fp.unpublished?).to be_truthy
      end
    end

    describe 'DELETE destroy' do
      it 'should change state and redirect' do
        fp = subject.current_user.posts.first
        delete :destroy, id: fp
        fp.reload
        expect(response).to redirect_to(action: :index)
        expect(fp.deleted?).to be_truthy
      end
    end
  end

  describe 'with the non-authenticated user' do
    it 'should redirect to index' do
      [:new, :tags].each do |act|
        get act
        expect(response).to redirect_to(new_user_session_path)
      end
      post :create
      expect(response).to redirect_to(new_user_session_path)

      post = FactoryGirl.create :post
      get :edit, id: post.id
      expect(response).to redirect_to(new_user_session_path)

      put :update, id: post.id
      expect(response).to redirect_to(new_user_session_path)

      delete :destroy, id: post.id
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
