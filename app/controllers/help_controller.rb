class HelpController < ApplicationController
  def index
  end

  def csv_curation
    @page_title = t("help.csv_curation.title")
  end
end
