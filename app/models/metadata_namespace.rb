class MetadataNamespace < ApplicationRecord
  belongs_to :metadata_format, optional: true

  before_create :set_id
  validates :namespace, presence: true

  private

  def set_id
    self.id = SecureRandom.uuid if self.id.nil?
  end
end
