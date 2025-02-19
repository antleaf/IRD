# frozen_string_literal: true
module Curation
  class SystemCuratorService < ApplicationService

    def call(system)
      begin
        service_result = Curation::PlatformAndGeneratorUpdaterService.call(system)
        system = service_result.payload if service_result.success?
        service_result = Curation::SystemOwnerFinderService.call(system)
        system = service_result.payload if service_result.success?
        service_result = Curation::SystemNamesProcessorService.call(system)
        system = service_result.payload if service_result.success?
        service_result = Curation::SystemRpUpdaterService.call(system)
        system = service_result.payload if service_result.success?
        service_result = Curation::SystemCandidateDefunctCheckerService.call(system)
        system = service_result.payload if service_result.success?
        success system
      rescue Exception => e
        Rails.logger.error("Error in SystemCuratorService: #{e.message}")
        failure e
      end
    end
  end
end