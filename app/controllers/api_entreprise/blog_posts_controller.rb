# frozen_string_literal: true

class APIEntreprise::BlogPostsController < APIEntrepriseController
  def show
    @blog_post = APIEntreprise::BlogPost.find(params[:id])

    render 'shared/blog_posts/show'
  end
end
