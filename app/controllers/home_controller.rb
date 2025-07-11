class HomeController < ApplicationController
  def index
    @page_title = t('page_titles.welcome')
    @stats = Stats::SystemSetStatsService.call(System.publicly_viewable, "All Repositories").payload
    continent_data = []
    Country.translated_continents.each do |translated_continent|
      systems = System.publicly_viewable.joins(:country).where(countries: { continent: translated_continent[2] })
      continent_data << ["#{translated_continent[0]} (#{systems.count})", systems.count]
    end
    @continent_graph_data = continent_data
  end

end