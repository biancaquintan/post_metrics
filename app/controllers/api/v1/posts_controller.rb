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

      def top_rated
        posts = Post.left_outer_joins(:ratings)
                    .select("posts.*, COALESCE(AVG(ratings.value), 0) AS average_rating")
                    .group("posts.id")
                    .order("average_rating DESC")

        posts = posts.limit(params[:limit]) if params[:limit].present?

        render json: posts.as_json(only: [ :id, :title, :body ])
      end

      def authors_ips_list
        posts = Post.includes(:user).all

        grouped_ips = posts.group_by(&:ip).map do |ip, posts|
          {
            ip: ip,
            logins: posts.map { |p| p.user.login }.uniq
          }
        end

        render json: grouped_ips, status: :ok
      end


      private

      def post_params
        params.require(:post).permit(:user_id, :title, :body, :ip)
      end
    end
  end
end
