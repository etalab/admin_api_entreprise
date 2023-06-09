SitemapGenerator::Sitemap.default_host = "https://particulier.api.gouv.fr"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/api-particulier"
SitemapGenerator::Sitemap.create do
  add api_particulier_stats_path
end
