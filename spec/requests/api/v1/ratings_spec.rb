require 'rails_helper'

RSpec.describe 'Ratings API', type: :request do
  describe 'POST /api/v1/ratings' do
    let(:user) { create(:user) }
    let(:post_record) { create(:post, user: user) }
    let(:valid_attributes) do
      {
        user_id: user.id,
        post_id: post_record.id,
        value: 4
      }
    end

    context 'when the request is valid' do
      it 'creates a new rating and returns the average rating' do
        post '/api/v1/ratings', params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(json['average_rating']).to eq(4.0)
      end

      it 'updates the average rating after multiple ratings' do
        another_user = create(:user)

        post '/api/v1/ratings', params: { user_id: user.id, post_id: post_record.id, value: 5 }
        post '/api/v1/ratings', params: { user_id: another_user.id, post_id: post_record.id, value: 3 }

        get_average = post_record.ratings.average(:value).to_f.round(2)

        expect(get_average).to eq(4.0)
      end
    end

    context 'when a user tries to rate the same post again' do
      it 'returns an error' do
        post '/api/v1/ratings', params: valid_attributes
        post '/api/v1/ratings', params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include('User has already rated this post')
      end
    end

    context 'when the request is invalid' do
      it 'returns validation errors when value is missing' do
        post '/api/v1/ratings', params: { user_id: user.id, post_id: post_record.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Value can't be blank")
      end

      it 'returns validation errors when value is out of range' do
        post '/api/v1/ratings', params: { user_id: user.id, post_id: post_record.id, value: 10 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include("Value must be less than or equal to 5")
      end
    end
  end

  def json
    JSON.parse(response.body)
  end
end
