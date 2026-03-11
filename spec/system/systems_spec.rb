require 'rails_helper'

RSpec.describe 'Systems Management', type: :system do
  describe 'Viewing systems list' do
    it 'displays the systems index page' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url
      expect(page).to have_current_path(systems_path)
      expect(page).to have_content('Systems')
    end

    it 'lists one system name' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      # Check that at least one system is listed
      system = System.publicly_viewable.where.not(name: nil).where.not(name: '').first
      if system.present?
        # The table displays display_name (short_name or name)
        expect(page).to have_content(system.display_name)
      else
        skip 'No publicly viewable systems available for testing'
      end
    end

    it 'shows total results count matching rows' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      # Get the total count from the database
      expected_count = System.publicly_viewable.count

      if expected_count == 0
        skip 'No publicly viewable systems available for testing'
      end

      # Extract the count from the total-results label (use first occurrence)
      total_results_text = first('.total-results').text
      label_count = total_results_text[/\d+/].to_i

      # Count the actual table rows
      row_count = all('table tbody tr').size

      # Verify the label matches the database count
      expect(label_count).to eq(expected_count), "Label shows #{label_count} but expected #{expected_count}"

      # Verify the rows match the label
      expect(row_count).to eq(label_count), "#{row_count} rows displayed but label shows #{label_count}"
    end

    it 'clicking system name navigates to show page' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      # Find a system with a name
      system = System.publicly_viewable.where.not(name: [ nil, '', "Unknown" ]).first

      if system.blank?
        skip 'No publicly viewable systems available for testing'
      end

      # Click on the system name link (displays as display_name in table)
      click_link system.display_name

      # Verify we're on the show page
      expect(page).to have_current_path(system_path(system), ignore_query: true)
      expect(page).to have_content(system.name)
    end

    it 'does not show non-verified systems in the index' do
      visit authenticate_as_url(email: users(:administrator).email)

      visible_system = System.create!(
        name: "Visible System #{SecureRandom.hex(4)}",
        short_name: "VS#{SecureRandom.hex(2).upcase}",
        url: 'https://visible.example.com/repository',
        platform_id: Platform.first.id,
        country_id: Country.first&.id || 'CH',
        rp_id: Organisation.first.id,
        record_status: :verified,
        system_status: :online,
        oai_status: :online,
        subcategory: :institutional_repository,
        primary_subject: :multidisciplinary,
        media_types: [ 'books' ]
      )

      hidden_system = System.create!(
        name: "Hidden System #{SecureRandom.hex(4)}",
        short_name: "HS#{SecureRandom.hex(2).upcase}",
        url: 'https://hidden.example.com/repository',
        platform_id: Platform.first.id,
        country_id: Country.first&.id || 'CH',
        rp_id: Organisation.first.id,
        record_status: :draft,
        system_status: :unknown,
        oai_status: :unknown,
        subcategory: :institutional_repository,
        primary_subject: :multidisciplinary,
        media_types: [ 'books' ]
      )

      visit systems_url

      expect(page).to have_content(visible_system.display_name)
      expect(page).not_to have_content(hidden_system.display_name)
    end
  end



  describe 'Creating a system' do
    # Standard users
    it 'standard user cannot access systems index' do
      visit authenticate_as_url(email: users(:user).email)
      visit systems_url

      # Standard users should not be authorized to view systems
      expect(page).to have_content('not authorized') || have_current_path(root_path)
    end

    # Admin users
    it 'admin user has create button and can click it' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      expect(page).to have_selector('.btn-primary', text: 'Create System Record')
      find('.btn-primary', text: 'Create System Record').click
      expect(page).to have_current_path(new_system_path, ignore_query: true)
    end

    it 'admin user can create a system and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      find('.btn-primary', text: 'Create System Record').click

      system_name = "Test System #{SecureRandom.hex(4)}"
      system_short_name = "TS#{SecureRandom.hex(2).upcase}"
      system_url = 'https://example.com/repository'
      system_description = 'Test repository description'
      system_contact = 'test@example.com'

      fill_in 'system[name]', with: system_name
      fill_in 'system[short_name]', with: system_short_name
      fill_in 'system[url]', with: system_url
      fill_in 'system[description]', with: system_description
      fill_in 'system[contact]', with: system_contact
      select 'Institutional', from: 'system[subcategory]'
      select 'Multidisciplinary', from: 'system[primary_subject]'

      click_button 'Save record'

      expect(page).to have_content('System was successfully created.')
      expect(page).to have_content(system_name)

      system = System.find_by!(name: system_name)
      expect(system.short_name).to eq(system_short_name)
      expect(system.url).to eq(system_url)
      expect(system.description).to eq(system_description)
      expect(system.contact).to eq(system_contact)
    end
  end

  describe 'Editing a system' do
    it 'admin user can edit a system and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)

      system = System.create!(
        name: "Editable System #{SecureRandom.hex(4)}",
        short_name: "ES#{SecureRandom.hex(2).upcase}",
        url: 'https://editable.example.com/repository',
        description: 'Original description',
        contact: 'editable@example.com',
        platform_id: Platform.first.id,
        country_id: Country.first&.id || 'CH',
        rp_id: Organisation.first.id,
        record_status: :draft,
        system_status: :unknown,
        oai_status: :unknown,
        subcategory: :institutional_repository,
        primary_subject: :multidisciplinary,
        media_types: [ 'books' ]
      )

      visit system_url(system)

      find('.btn-primary', text: 'Edit').click

      updated_name = "Updated System #{SecureRandom.hex(4)}"
      updated_short_name = "US#{SecureRandom.hex(2).upcase}"
      updated_url = 'https://updated.example.com/repository'
      updated_description = 'Updated repository description'

      fill_in 'system[name]', with: updated_name
      fill_in 'system[short_name]', with: updated_short_name
      fill_in 'system[url]', with: updated_url
      fill_in 'system[description]', with: updated_description

      click_button 'Save record'

      expect(page).to have_content('System was successfully updated.')
      expect(page).to have_content(updated_name)

      system.reload
      expect(system.name).to eq(updated_name)
      expect(system.short_name).to eq(updated_short_name)
      expect(system.url).to eq(updated_url)
      expect(system.description).to eq(updated_description)
    end
  end

describe 'Searching systems' do
    it 'admin user can search for systems by name' do
      # Create a verified system that will be searchable
      test_system = System.create!(
        name: 'Test Searchable Repository',
        short_name: 'TSR',
        url: 'https://test-searchable.example.com',
        platform_id: Platform.first.id,
        country_id: Country.first&.id || 'CH',
        rp_id: Organisation.first.id,
        record_status: :verified,
        system_status: :online,
        oai_status: :online,
        subcategory: :institutional_repository,
        primary_subject: :multidisciplinary,
        media_types: [ 'books' ]
      )

      # Refresh the search index to make the new system immediately searchable
      System.search_index.refresh

      # Authenticate as administrator
      visit authenticate_as_path(email: users(:administrator).email)

      # Visit systems index first to establish session
      visit systems_path
      expect(page).to have_content('Systems')

      # Now visit search page with search parameter
      visit system_search_path(search: 'Searchable')

      # Verify search results are displayed (table renders display_name)
      expect(page).to have_content(test_system.display_name)
      expect(page).to have_content('Systems')
    end
  end
end
