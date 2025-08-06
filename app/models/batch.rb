class Batch < ApplicationRecord
  belongs_to :user
  belongs_to :rp, class_name: "Organisation", optional: false

  scope :locking, -> { where(locking: true) }
end
