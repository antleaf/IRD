Searchkick.model_options = {
  batch_size: ENV.fetch("OPENSEARCH_BATCH_SIZE", 1000).to_i
}
if ENV["OPENSEARCH_CA_CERT_PATH"].present? && File.exist?(ENV["OPENSEARCH_CA_CERT_PATH"])
  Searchkick.client_options = {
    transport_options: {
      ssl: {
        verify: false,
        ca_file: ENV["OPENSEARCH_CA_CERT_PATH"]
      }
    }
  }
end
