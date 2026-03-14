module SearchkickHelpers
  def reindex_for_search!(*records)
    records.flatten.compact.each do |record|
      record.reindex(refresh: true)
    end
  end
end
