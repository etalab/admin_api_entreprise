SitemapGenerator::Sitemap.default_host = "https://entreprise.api.gouv.fr"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/api-entreprise"

SitemapGenerator::Sitemap.create do
  add root_path

  add mentions_path
  add cgu_path
  add donnees_personnelles_path
  add accessibilite_path

  add login_path

  add faq_index_path
  add newsletter_path
  add stats_path

  add developers_path
  add developers_openapi_path

  APIEntreprise::BlogPost.all.each do |blog_post|
    add blog_post_path(id: blog_post.id)
  end

  add cas_usages_path

  APIEntreprise::CasUsage.all.each do |cas_usage|
    add cas_usage_path(uid: cas_usage.uid)
  end

  add endpoints_path

  APIEntreprise::Endpoint.all.reject(&:deprecated).each do |endpoint|
    add endpoint_path(uid: endpoint.id)
  end
end
