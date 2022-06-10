class DocController < ApplicationController
  layout 'no_container', only: %i[developers guide_migration]

  def developers
    @doc_entries = DocEntry.developers

    render 'index'
  end

  def guide_migration
    @doc_entries = DocEntry.guide_migration

    render 'index'
  end
end
