# frozen_string_literal: true

class CasUsagesController < ApplicationController
  layout 'no_container'

  def index; end

  def show
    @cas_usage_tag = params[:uid]
    @cas_usage_name = I18n.t("cas_usages_entries.#{@cas_usage_tag}.name", raise: true)
    @data = I18n.t("cas_usages_entries.#{@cas_usage_tag}", raise: true)
  rescue I18n::MissingTranslationData
    redirect_to root_path
  end
end
