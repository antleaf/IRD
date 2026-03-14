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
      system = System.publicly_viewable.order(:name).where.not(name: nil).where.not(name: '').first
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

      # Verify the rows on the current page don't exceed the page size (index is paginated)
      page_size = Pagy::DEFAULT[:limit]
      expect(row_count).to be <= page_size,
        "#{row_count} rows displayed but page size is #{page_size}"
      expect(row_count).to be <= label_count,
        "#{row_count} rows displayed but label shows only #{label_count} total"
    end

    it 'clicking system name navigates to show page' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit systems_url

      # Find a system using the same scope/order as the systems index
      system = System.publicly_viewable.order(:name).where.not(name: [ nil, '', "Unknown" ]).first

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

      visible_system = systems(:zenodo)
      hidden_system = systems(:hidden_draft)

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
      unauthorized_feedback_present = page.has_content?('not authorized') || page.has_current_path?(root_path, ignore_query: true)
      expect(unauthorized_feedback_present).to be(true)
    end

    it 'admin user can create a system and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit new_system_url

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
      visit new_system_url

      editable_name = "Editable System #{SecureRandom.hex(4)}"
      editable_short_name = "ES#{SecureRandom.hex(2).upcase}"

      fill_in 'system[name]', with: editable_name
      fill_in 'system[short_name]', with: editable_short_name
      fill_in 'system[url]', with: 'https://editable.example.com/repository'
      fill_in 'system[description]', with: 'Original description'
      fill_in 'system[contact]', with: 'editable@example.com'
      select 'Institutional', from: 'system[subcategory]'
      select 'Multidisciplinary', from: 'system[primary_subject]'

      click_button 'Save record'

      system = System.find_by!(name: editable_name)

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
      test_system = systems(:zenodo)

      # Ensure fixture-backed record is in the search index for this test run
      reindex_for_search!(test_system)

      # Authenticate as administrator
      visit authenticate_as_url(email: users(:administrator).email)

      # Visit systems index first to establish session
      visit systems_url
      expect(page).to have_content('Systems')

      # Now visit search page with search parameter
      visit system_search_url(search: 'Zenodo')

      # Verify search results are displayed (table renders display_name)
      expect(page).to have_content(test_system.display_name)
      expect(page).to have_content('Systems')
    end

    it 'reflects a newly added system in search results after indexing' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit new_system_url

      system_name = "Indexed Search System #{SecureRandom.hex(4)}"
      system_short_name = "ISS#{SecureRandom.hex(2).upcase}"

      fill_in 'system[name]', with: system_name
      fill_in 'system[short_name]', with: system_short_name
      fill_in 'system[url]', with: 'https://indexed-search.example.com/repository'
      fill_in 'system[description]', with: 'Search indexing coverage test'
      fill_in 'system[contact]', with: 'search-indexing@example.com'
      select 'Institutional', from: 'system[subcategory]'
      select 'Multidisciplinary', from: 'system[primary_subject]'

      click_button 'Save record'
      expect(page).to have_content('System was successfully created.')

      created_system = System.find_by!(name: system_name)
      reindex_for_search!(created_system)

      visit system_search_url(search: system_name)

      expect(page).to have_content(created_system.display_name)
      expect(page).to have_content('Systems')
    end
  end
end
