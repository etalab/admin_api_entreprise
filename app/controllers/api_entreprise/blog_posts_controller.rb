# frozen_string_literal: true

class APIEntreprise::BlogPostsController < APIEntrepriseController
  def show
    @blog_post = BlogPost.find(params[:id])
  end
end
