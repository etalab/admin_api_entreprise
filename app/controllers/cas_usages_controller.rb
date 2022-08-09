# frozen_string_literal: true

class CasUsagesController < ApplicationController
  layout 'no_container'

  def index; end

  def show
    @data = I18n.t("cas_usages_entries.#{params[:uid]}", raise: true)
  rescue I18n::MissingTranslationData
    redirect_to root_path
  end
end
