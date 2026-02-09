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
      expect(page).to have_content(platform.name)
    end
  end

  describe 'Creating a platform' do
     # Standard users
     it 'standard user has no create button' do
      visit authenticate_as_url(email: users(:user).email)
      visit platforms_url

      expect(page).not_to have_selector('.btn-primary', text: 'Create Platform Record')
    end
    # Admin users
    it 'admin user has create button and can click it' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit platforms_url

      expect(page).to have_selector('.btn-primary', text: 'Create Platform Record')
      find('.btn-primary', text: 'Create Platform Record').click
      expect(page).to have_current_path(new_platform_path, ignore_query: true)
    end
    it 'admin user can create a platform and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit platforms_url

      find('.btn-primary', text: 'Create Platform Record').click
      platform_name = "Test Platform #{SecureRandom.hex(4)}"
      platform_url = 'https://example.com'
      platform_matcher = '/example\\.com/'
      platform_generator_pattern = '/example/'
      platform_match_order = '99.0'
      platform_oai_suffix = 'test_suffix'

      fill_in 'platform[name]', with: platform_name
      fill_in 'platform[url]', with: platform_url
      find('input[name="platform[trusted]"]').set(true)
      first('input[name="platform[matchers][]"]').set(platform_matcher)
      first('input[name="platform[generator_patterns][]"]').set(platform_generator_pattern)
      fill_in 'platform[match_order]', with: platform_match_order
      find('input[name="platform[oai_support]"]').set(true)
      fill_in 'platform[oai_suffix]', with: platform_oai_suffix

      click_button 'Save record'

      expect(page).to have_content('Platform was successfully created.')
      expect(page).to have_content(platform_name)

      platform = Platform.find_by!(name: platform_name)
      expect(platform.url).to eq(platform_url)
      expect(platform.trusted).to eq(true)
      expect(platform.matchers).to include(platform_matcher)
      expect(platform.generator_patterns).to include(platform_generator_pattern)
      expect(platform.match_order).to eq(99.0)
      expect(platform.oai_support).to eq(true)
      expect(platform.oai_suffix).to eq(platform_oai_suffix)
    end
  end
end
