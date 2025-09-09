class MetadataNamespace < ApplicationRecord
  belongs_to :metadata_format, optional: true
end
