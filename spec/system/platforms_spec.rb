require 'rails_helper'

RSpec.describe 'Platforms Management', type: :system do
  describe 'Viewing platforms list' do
    it 'displays the platforms index page' do
      visit platforms_path
      expect(page).to have_current_path(platforms_path)
      expect(page).to have_content('Platforms')
    end

    it 'lists one platform name' do
      visit platforms_path
      # Check that at least one platform is listed
      platform = Platform.where.not(name: nil).where.not(name: '').first
      if platform&.name.present?
        expect(page).to have_content(platform.name)
      end
    end

    it 'shows total results count matching rows' do
      visit platforms_path

      # Get the total count from the database
      expected_count = Platform.count

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

    it 'clicking platform name navigates to show page' do
      visit platforms_path

      # Find a platform with a name
      platform = Platform.where.not(name: [ nil, '', "Unknown" ]).first
      expect(platform).to be_present

      # Click on the platform name link
      click_link platform.name

      # Verify we're on the show page
      expect(page).to have_current_path(platform_path(platform), ignore_query: true)
      expect(page).to have_content(platform.name)
    end
  end

  describe 'Creating a platform' do
    it 'clicking create button brings up the create form' do
      # Sign in as administrator
      visit authenticate_as_url(email: users(:administrator).email)

      # Navigate to platforms page
      visit platforms_path

      # Click the create button (using CSS class selector to find the button)
      find('.btn-primary', text: 'Create Platform Record').click

      # Verify we're on the new platform page (ignoring query parameters like ?lang=en)
      expect(page).to have_current_path(new_platform_path, ignore_query: true)
    end
  end
end
