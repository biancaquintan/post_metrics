module Api
  module V1
    class PostsController < BaseController
      def create
        user = User.find_or_create_by!(login: params[:login])

        post = user.posts.new(
          title: params[:title],
          body: params[:body],
          ip: params[:ip]
        )

        if post.save
          render json: {
            post: post,
            user: user
          }, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def post_params
        params.require(:post).permit(:user_id, :title, :body, :ip)
      end
    end
  end
end
