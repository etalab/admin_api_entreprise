class DocController < ApplicationController
  layout 'no_container', only: %i[index guide_migration]

  def developers
    @developers_entries = DocEntry.developers
  end

  def guide_migration
    @migration_entries = DocEntry.guide_migration
  end
end
