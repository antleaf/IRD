json.extract! batch, :id, :filename, :user_id, :rp_id, :locking, :notes, :created_at, :updated_at
json.url batch_url(batch, format: :json)
