require 'rails_helper'

RSpec.describe 'Organisations Management', type: :system do
  describe 'Viewing organisations list' do
    it 'displays the organisations index page' do
      visit organisations_url
      expect(page).to have_current_path(organisations_path)
      expect(page).to have_content('Organisations')
    end

    it 'lists one organisation display_name' do
      visit organisations_url

      organisation = Organisation.where.not(name: nil).where.not(name: '').first
      if organisation.present? && organisation.name != 'Unknown'
        expect(page).to have_content(organisation.display_name) or have_content(organisation.name)
      end
    end

    it 'shows total results count matching rows' do
      visit organisations_url

      expected_count = Organisation.count

      total_results_text = first('.total-results').text
      label_count = total_results_text[/\d+/].to_i

      row_count = all('table tbody tr').size

      expect(label_count).to eq(expected_count), "Label shows #{label_count} but expected #{expected_count}"
      expect(row_count).to eq(label_count), "#{row_count} rows displayed but label shows #{label_count}"
    end

    it 'clicking organisation name navigates to show page' do
      visit organisations_url

      organisation = Organisation.where.not(name: [ nil, '', 'Unknown' ]).first
      expect(organisation).to be_present

      click_link organisation.display_name

      expect(page).to have_current_path(organisation_path(organisation), ignore_query: true)
      expect(page).to have_content(organisation.name)
    end
  end

  describe 'Creating an organisation' do
    # Standard users
    it 'standard user has no create button' do
      visit authenticate_as_url(email: users(:user).email)
      visit organisations_url

      expect(page).not_to have_selector('.btn-primary', text: 'Create Organisation Record')
    end

    # Admin users
    it 'admin user has create button and can click it' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit organisations_url

      expect(page).to have_selector('.btn-primary', text: 'Create Organisation Record')
      find('.btn-primary', text: 'Create Organisation Record').click
      expect(page).to have_current_path(new_organisation_path, ignore_query: true)
    end

    it 'admin user can create an organisation and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)
      visit organisations_url

      find('.btn-primary', text: 'Create Organisation Record').click

      organisation_name = "Test Organisation #{SecureRandom.hex(4)}"
      organisation_short_name = "TO#{SecureRandom.hex(2).upcase}"
      organisation_website = 'https://example.org'
      organisation_alias = 'Example Org Alias'
      organisation_ror = "https://ror.org/#{SecureRandom.alphanumeric(9).downcase}"
      organisation_location = 'Test City, Test Country'

      fill_in 'organisation[name]', with: organisation_name
      fill_in 'organisation[short_name]', with: organisation_short_name
      fill_in 'organisation[website]', with: organisation_website
      first('input[name="organisation[aliases][]"]').set(organisation_alias)
      fill_in 'organisation[ror]', with: organisation_ror
      fill_in 'organisation[location]', with: organisation_location
      select 'Switzerland', from: 'organisation[country_id]'

      click_button 'Save record'

      expect(page).to have_content('Organisation was successfully created.')
      expect(page).to have_content(organisation_name)

      organisation = Organisation.find_by!(name: organisation_name)
      expect(organisation.short_name).to eq(organisation_short_name)
      expect(organisation.website).to eq(organisation_website)
      expect(organisation.aliases).to include(organisation_alias)
      expect(organisation.ror).to eq(organisation_ror)
      expect(organisation.location).to eq(organisation_location)
      expect(organisation.country_id).to eq('CH')
    end
  end

  describe 'Editing an organisation' do
    # Standard users
    it 'standard user has no edit button' do
      visit authenticate_as_url(email: users(:user).email)

      organisation = Organisation.where.not(name: [ nil, '', 'Unknown' ]).first
      expect(organisation).to be_present

      visit organisation_url(organisation)
      expect(page).not_to have_selector('.btn-primary', text: 'Edit')
    end

    # Admin users
    it 'admin user can edit an organisation and correct values are saved' do
      visit authenticate_as_url(email: users(:administrator).email)

      organisation = Organisation.where.not(name: [ nil, '', 'Unknown' ]).first
      expect(organisation).to be_present

      visit organisation_url(organisation)
      expect(page).to have_current_path(organisation_path(organisation), ignore_query: true)

      find('.btn-primary', text: 'Edit').click

      updated_name = "Updated Organisation #{SecureRandom.hex(4)}"
      updated_location = 'Updated City, Updated Country'

      fill_in 'organisation[name]', with: updated_name
      fill_in 'organisation[location]', with: updated_location

      click_button 'Save record'

      expect(page).to have_content('Organisation was successfully updated.')
      expect(page).to have_content(updated_name)

      organisation.reload
      expect(organisation.name).to eq(updated_name)
      expect(organisation.location).to eq(updated_location)
    end
  end
end
