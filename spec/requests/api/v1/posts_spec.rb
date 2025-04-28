require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  describe 'POST /api/v1/posts' do
    let(:valid_attributes) do
      {
        login: Faker::Internet.unique.username,
        title: Faker::Movie.title,
        body: Faker::Lorem.paragraph,
        ip: Faker::Internet.private_ip_v4_address
      }
    end

    context 'when the request is valid' do
      it 'creates a new post and a user if not existing' do
        expect {
          post '/api/v1/posts', params: valid_attributes
        }.to change(Post, :count).by(1)
         .and change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json['post']['title']).to eq(valid_attributes[:title])
        expect(json['user']['login']).to eq(valid_attributes[:login])
      end

      it 'creates a new post for existing user without creating new user' do
        user = create(:user, login: valid_attributes[:login])

        expect {
          post '/api/v1/posts', params: valid_attributes.merge(login: user.login)
        }.to change(Post, :count).by(1)
         .and change(User, :count).by(0)

        expect(response).to have_http_status(:created)
        expect(json['post']['title']).to eq(valid_attributes[:title])
        expect(json['user']['login']).to eq(valid_attributes[:login])
      end
    end

    context 'when the request is invalid' do
      it 'returns validation errors when title is blank' do
        post '/api/v1/posts', params: valid_attributes.merge(title: '')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Title can't be blank")
      end

      it 'returns validation errors when body is blank' do
        post '/api/v1/posts', params: valid_attributes.merge(body: '')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Body can't be blank")
      end

      it 'returns validation errors when IP is blank' do
        post '/api/v1/posts', params: valid_attributes.merge(ip: '')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Ip can't be blank")
      end

      it 'returns validation errors when IP is invalid' do
        post '/api/v1/posts', params: valid_attributes.merge(ip: 'invalid_ip')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Ip is invalid")
      end
    end
  end

  describe 'GET /api/v1/posts/top_rated' do
    let!(:post1) { create(:post, title: Faker::Movie.title) }
    let!(:post2) { create(:post, title: Faker::Movie.title) }
    let!(:post3) { create(:post, title: Faker::Movie.title) }
    let!(:post_without_rating) { create(:post, title: Faker::Movie.title) }

    before do
      create_list(:rating, 2, post: post1, value: 5)
      create(:rating, post: post2, value: 4)
      create(:rating, post: post3, value: 2)
    end

    context 'when limit is provided' do
      it 'returns the top N posts by average rating' do
        get '/api/v1/posts/top_rated', params: { limit: 2 }

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(2)
        expect(json.map { |p| p['title'] }).to eq([ post1.title, post2.title ])
      end
    end

    context 'when no limit is provided' do
      it 'returns all posts ordered by average rating' do
        get '/api/v1/posts/top_rated'

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(4)
        expect(json.map { |p| p['title'] }).to include(post1.title, post2.title, post3.title, post_without_rating.title)
      end
    end

    context 'when posts have no ratings' do
      it 'includes posts with no ratings with average 0' do
        get '/api/v1/posts/top_rated'

        expect(response).to have_http_status(:ok)
        expect(json.map { |p| p['title'] }).to include(post_without_rating.title)
      end
    end
  end


  def json
    JSON.parse(response.body)
  end
end
