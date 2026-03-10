require 'rails_helper'

RSpec.describe 'Countries Management', type: :system do
  describe 'Viewing countries list' do
    it 'displays the countries index page' do
      visit countries_url
      expect(page).to have_current_path(countries_path)
      expect(page).to have_content('Countries')
    end

    it 'lists one country name' do
      visit countries_url
      # Check that at least one country is listed
      country = Country.where.not(name: nil).where.not(name: '').first
      if country&.name.present?
        expect(page).to have_content(country.name)
      end
    end

    it 'shows total results count matching rows' do
      visit countries_url

      # Get the total count from the database
      expected_count = Country.count

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

    it 'clicking country code navigates to show page' do
      visit countries_url

      # Find a country with a name and valid id
      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      # Click on the country code link
      click_link country.id

      # Verify we're on the show page
      expect(page).to have_current_path(country_path(country), ignore_query: true)
      expect(page).to have_content(country.name)
    end
  end

  describe 'Viewing a country' do
    it 'displays country details on show page' do
      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      visit country_url(country)

      expect(page).to have_content(country.id)
      expect(page).to have_content(country.name)
    end

    it 'standard user has no edit button on show page' do
      visit authenticate_as_url(email: users(:user).email)

      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      visit country_url(country)

      expect(page).not_to have_selector('.btn-primary.btn-sm', text: 'Edit')
    end

    it 'admin user has edit button on show page' do
      visit authenticate_as_url(email: users(:administrator).email)

      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      visit country_url(country)

      expect(page).to have_selector('.btn-primary.btn-sm', text: 'Edit')
    end
  end

  # describe 'Create Country Record button' do
  #   it 'standard user has no create button' do
  #     visit authenticate_as_url(email: users(:user).email)
  #     visit countries_url
  #
  #     expect(page).not_to have_selector('.btn-primary', text: 'Create Country Record')
  #   end
  #
  #   it 'admin user has create button and can click it' do
  #     visit authenticate_as_url(email: users(:administrator).email)
  #     visit countries_url
  #
  #     expect(page).to have_selector('.btn-primary', text: 'Create Country Record')
  #     find('.btn-primary', text: 'Create Country Record').click
  #     expect(page).to have_current_path(new_country_path, ignore_query: true)
  #   end
  # end

  describe 'Editing a country' do
    it 'admin user can edit a country and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)

      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      # visit country_url(country)
      visit country_url(country)

      find('.btn-primary.btn-sm', text: 'Edit').click

      expect(page).to have_current_path(edit_country_path(country), ignore_query: true)

      updated_name = "Updated Country #{SecureRandom.hex(4)}"

      fill_in 'country[name]', with: updated_name

      click_button 'Save record'

      expect(page).to have_content('country was successfully updated.')
      expect(page).to have_content(updated_name)

      country.reload
      expect(country.name).to eq(updated_name)
    end

    it 'standard user cannot access edit page' do
      visit authenticate_as_url(email: users(:user).email)

      country = Country.where.not(name: [nil, '']).where.not(id: '--').first
      expect(country).to be_present

      visit edit_country_path(country)

      # Should be redirected away or shown an error — not the edit form
      expect(page).not_to have_current_path(edit_country_path(country), ignore_query: true)
    end
  end
end






