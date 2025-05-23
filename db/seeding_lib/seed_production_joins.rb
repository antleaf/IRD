require 'csv'

def seed_network_checks
  CSV.foreach(('./data/export_production_csv/network_checks.csv'), headers: true) do |row|
    NetworkCheck.create!(
      id: row['id'],
      passed: row['passed']=='true',
      network_check_type: row['network_check_type'].to_i,
      http_code: row['http_code'].to_i,
      description: row['description'],
      system: System.find(row['system_id']),
      failures: row['failures'].to_i,
      error_at: row['error_at']
    )
  end
end

def seed_normalids
  CSV.foreach(('./data/export_production_csv/normalids.csv'), headers: true) do |row|
    Normalid.create!(
      id: row['id'],
      url: row['url'],
      domain: row['domain'],
      system: System.find(row['system_id']),
    )
  end
end

def seed_all_production_joins
  # seed_network_checks
  # seed_normalids
end