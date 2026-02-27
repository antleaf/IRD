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
