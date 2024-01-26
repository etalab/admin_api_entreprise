SitemapGenerator::Sitemap.default_host = "https://particulier.api.gouv.fr"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/api-particulier"
SitemapGenerator::Sitemap.create do
  add api_particulier_stats_path

  add api_particulier_cas_usages_path

  APIParticulier::CasUsage.all.each do |cas_usage|
    add api_particulier_cas_usage_path(uid: cas_usage.uid)
  end
end
