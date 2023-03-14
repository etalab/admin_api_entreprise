SitemapGenerator::Sitemap.default_host = "https://entreprise.api.gouv.fr"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/api-entreprise"
SitemapGenerator::Sitemap.create do

  add root_path

  add newsletter_path
  add mentions_path
  add cgu_path
  add accessibilite_path
  add login_path
  add developers_openapi_path
  add faq_index_path
  
  BlogPost.all.each do |blog_post|
    add blog_post_path(id: blog_post.id)
  end

  CasUsage.all.each do |cas_usage|
    add cas_usage_path(uid: cas_usage.uid)
  end
  add cas_usages_path

  add dashboard_root_path
  add logout_path
  add stats_path
  add user_profile_path
  add authorization_requests_path
  add attestations_path
  add search_attestations_path
  add user_tokens_path
  
  Token.all.each do |token|
    add token_stats_path(token)
  end
  
  add public_magic_link_create_path
  add transfer_account_path
  add compte_transferer_path
  add endpoints_path

  AvailableEndpoints.all.each do |endpoint|
    add endpoint_path(uid: endpoint['uid'])
  end
  
  add developers_path
  add guide_migration_path

  add login_api_gouv_entreprise_path
  add login_api_gouv_particulier_path

end
