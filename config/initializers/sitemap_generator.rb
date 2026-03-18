require 'cgi'

module SitemapGenerator
  class LinkSet
    def ping_search_engines(*args) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      require 'open-uri'
      require 'timeout'

      engines = args.last.is_a?(Hash) ? args.pop : {}
      unescaped_url = args.shift || sitemap_index_url
      index_url = CGI.escape(unescaped_url)

      output("\n")
      output("Pinging with URL '#{unescaped_url}':")
      search_engines.merge(engines).each do |engine, link|
        link %= index_url
        name = Utilities.titleize(engine.to_s)
        Timeout.timeout(10) do
          URI.open(link) # rubocop:disable Security/Open
        end
        output("  Successful ping of #{name}")
      rescue StandardError => e
        output("Ping failed for #{name}: #{e.inspect} (URL #{link})")
      end
    end
  end
end
