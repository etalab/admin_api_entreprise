# frozen_string_literal: true

class APIParticulier::BlogPostsController < APIParticulierController
  def show
    @blog_post = APIParticulier::BlogPost.find(params[:id])

    render 'shared/blog_posts/show'
  end
end
