class PagesController < ApplicationController
  layout 'no_container', only: %i[home developers guide_migration]

  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def home
    @endpoints_sample = Endpoint.all.sample(3)
    @providers = Provider.all
  end

  def developers
    @doc_developers = File.read('config/doc/developpeurs.md')
  end

  def guide_migration
    @doc_migration = File.read('config/doc/guide-migration.md')
  end

  def mentions; end

  def cgu; end

  def redoc; end
end
