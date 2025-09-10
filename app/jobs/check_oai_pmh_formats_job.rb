class CheckOaiPmhFormatsJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    OaiPmh::OaiPmhMetadataFormatsService.call(system_id).payload
  end

end
