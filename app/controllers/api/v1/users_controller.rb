module Api
  module V1
    class UsersController < ApplicationController
      def create
        user = User.find_or_create_by!(login: params[:login])

        render json: { user: user }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end