class GetItemCountViaOaiPmhJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    OaiPmh::OaiPmhRecordCountService.call(system_id).payload
  end

end
