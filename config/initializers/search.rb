Searchkick.model_options = {
  batch_size: ENV.fetch('OPENSEARCH_BATCH_SIZE',1000).to_i
}

Searchkick.client_options = {
    transport_options: {
      ssl: {
        verify: false,
      }
    }
  }