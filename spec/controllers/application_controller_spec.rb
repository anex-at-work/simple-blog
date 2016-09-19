require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe '#render_404' do
    before do
      def controller.index
        raise ActiveRecord::RecordNotFound
      end
    end

    it 'renders the 404 page with' do
      get :index
      expect(response.code).to eq "404"
      expect(response).to render_template("404")
    end
  end
end
