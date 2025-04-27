require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  describe 'POST /api/v1/posts' do
    let(:valid_attributes) do
      {
        login: 'new_user',
        title: 'Test Post',
        body: 'This is a test body.',
        ip: '192.168.1.1'
      }
    end

    context 'when the request is valid' do
      it 'creates a new post and a user if not existing' do
        expect {
          post '/api/v1/posts', params: valid_attributes
        }.to change(Post, :count).by(1)
         .and change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json['post']['title']).to eq('Test Post')
        expect(json['user']['login']).to eq('new_user')
      end

      it 'creates a new post for existing user without creating new user' do
        user = create(:user, login: 'new_user')

        expect {
          post '/api/v1/posts', params: valid_attributes.merge(login: user.login)
        }.to change(Post, :count).by(1)
         .and change(User, :count).by(0)

        expect(response).to have_http_status(:created)
        expect(json['post']['title']).to eq('Test Post')
        expect(json['user']['login']).to eq('new_user')
      end
    end

    context 'when the request is invalid' do
      it 'returns validation errors when title is blank' do
        post '/api/v1/posts', params: { login: 'new_user', title: '', body: 'Test Body', ip: '192.168.1.1' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Title can't be blank")
      end

      it 'returns validation errors when body is blank' do
        post '/api/v1/posts', params: { login: 'new_user', title: 'Test Post', body: '', ip: '192.168.1.1' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Body can't be blank")
      end

      it 'returns validation errors when IP is blank' do
        post '/api/v1/posts', params: { login: 'new_user', title: 'Test Post', body: 'Test Body', ip: '' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Ip can't be blank")
      end

      it 'returns validation errors when IP is invalid' do
        post '/api/v1/posts', params: { login: 'new_user', title: 'Test Post', body: 'Test Body', ip: 'invalid_ip' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Ip is invalid")
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
