# frozen_string_literal: true
require "nokogiri"

module OaiPmh
  class OaiPmhMetadataFormatsService < ApplicationService

    def call(system_id, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks, :repoids, :users).find(system_id)
        original_url = @system.oai_base_url
        unless original_url.present?
          Rails.logger.warn("OAI-PMH Base URL missing for OAI-PMH ListMetadataFormats #{original_url}")
          return system # return early if no OAI-PMH base URL
        end
        url_with_verb_list_metadata_formats = Utilities::OaiPmhUrlFormatter.with_verb_list_metadata_formats(original_url)
        Rails.logger.debug("Running OAI-PMH Check Formats on #{url_with_verb_list_metadata_formats}")
        conn = Utilities::HttpClientConnectionWrapper.new(redirect_limit)
        response = conn.get(url_with_verb_list_metadata_formats)
        doc = Nokogiri::XML(response.body)
        doc.remove_namespaces!

        @system.formats = {}
        doc.xpath("//metadataFormat").each do |format|
          @system.formats[format.at_xpath("metadataPrefix").text.strip] = {
            namespace: (format.at_xpath("metadataNamespace").text.strip if format.at_xpath("metadataNamespace")),
            schema: (format.at_xpath("schema").text.strip if format.at_xpath("schema"))
          }
        end
        @system.metadata_formats.clear
        @system.formats.each_pair do |prefix, format|
          unless format[:namespace].blank?
            mn = MetadataNamespace.find_by(namespace: format[:namespace])
            if mn.present?
              if mn.metadata_format.present?
                @system.metadata_formats << mn.metadata_format unless @system.metadata_formats.include?(mn.metadata_format)
                @system.formats.delete(prefix)
              end
            else
              MetadataNamespace.create!(
                namespace: format[:namespace]
              )
            end
          end
        end
      rescue StandardError => e
        Rails.logger.warn "CheckOaiPmhFormatsJob: #{e.message}"
        failure e
      else
        success @system
      ensure
        begin
          Audited.audit_class.as_user(User.system_user) do
            @system.save!
          end
        rescue Exception => e2
          Rails.logger.error("CheckOaiPmhFormatsJob: #{e2.message}")
        end
      end
    end
  end
end
