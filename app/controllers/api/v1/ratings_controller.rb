module Api
  module V1
    class RatingsController < BaseController
      def create
        Rating.transaction do
          rating = Rating.create!(
            user_id: params[:user_id],
            post_id: params[:post_id],
            value: params[:value]
          )

          average_rating = rating.post.ratings.average(:value).to_f.round(2)

          render json: { average_rating: average_rating }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: [ "User has already rated this post" ] }, status: :unprocessable_entity
      end

      def batch_create
        ratings = params.require(:ratings)

        Rating.transaction do
          ratings.each do |rating_params|
            Rating.create!(
              user_id: rating_params[:user_id],
              post_id: rating_params[:post_id],
              value: rating_params[:value]
            )
          end
        end

        render json: { message: "Batch ratings created successfully" }, status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: [ "A user has already rated this post." ] }, status: :unprocessable_entity
      rescue ActionController::ParameterMissing => e
        render json: { errors: [ e.message ] }, status: :bad_request
      end
    end
  end
end
