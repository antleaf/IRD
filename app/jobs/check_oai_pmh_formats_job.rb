class CheckOaiPmhFormatsJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = OaiPmh::OaiPmhMetadataFormatsService.call(system_id).payload
    if system.present?
      Curation::SystemMetadataFormatAssociationService.call(system)
    end
  end

end
