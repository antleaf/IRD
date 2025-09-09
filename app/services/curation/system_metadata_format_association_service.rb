# frozen_string_literal: true

module Curation
  class SystemMetadataFormatAssociationService < ApplicationService
    def call(system)
      begin
        system.metadata_formats.clear
        system.formats.each_pair do |prefix,format|
          mn = MetadataNamespace.find_by_id(format["namespace"])
          if mn.present?
            if mn.metadata_format.present?
              system.metadata_formats << mn.metadata_format unless system.metadata_formats.include?(mn.metadata_format)
            end
          else
            MetadataNamespace.create!(
              id: format["namespace"]
            )
          end
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in SystemMetadataFormatAssociationService: #{e.message}")
        failure e
      end
    end
  end
end
