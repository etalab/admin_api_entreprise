class ProviderStatsFacade
  def initialize(provider)
    @provider = provider
  end

  def stats_metabase_urls
    @stats_metabase_urls ||= {
      main: {
        height: '3200px',
        metabase_url: build_main_stats
      },
      users: {
        height: '500px',
        metabase_url: build_users_stats
      },
      habilitations: {
        height: '600px',
        metabase_url: build_habilitations_stats
      }
    }
  end

  private

  def build_habilitations_stats
    MetabaseEmbedService.new(
      resource: {
        question: 547
      },
      params: {
        scopes: scopes.join(',')
      }
    ).url
  end

  def build_users_stats
    MetabaseEmbedService.new(
      resource: {
        question: 554
      },
      params: {
        route: routes.join(',')
      }
    ).url
  end

  def build_main_stats
    MetabaseEmbedService.new(
      resource: {
        dashboard: main_stats_dashboard_id
      },
      params: {
        routes: routes.join(',')
      }
    ).url
  end

  def main_stats_dashboard_id
    if @provider.uid == 'cnav'
      102
    else
      97
    end
  end

  def scopes
    @provider.scopes.presence || ['open_data_unites_legales_etablissements_insee']
  end

  def routes
    @provider.routes_or_uid_to_match || []
  end
end
