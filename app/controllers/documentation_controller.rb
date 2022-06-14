class DocumentationController < ApplicationController
  layout 'no_container', only: %i[developers guide_migration]

  def developers
    @documentation_entries = DocumentationEntry.developers

    render 'index'
  end

  def guide_migration
    @documentation_entries = DocumentationEntry.guide_migration

    render 'index'
  end
end
