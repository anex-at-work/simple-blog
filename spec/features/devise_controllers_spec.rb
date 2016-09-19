require 'rails_helper'

RSpec.feature "DeviseControllers", type: :feature do
  describe 'sign_in' do
    it 'should prohibit authorization with invalid fields' do
      visit new_user_session_path
      click_button I18n.t('helpers.buttons.sign_in')
      expect(page).to have_css('.alert.alert-danger')
    end

    it 'should authorize the correct user by email' do
      user = FactoryGirl.create :user
      visit new_user_session_path
      fill_in 'user_login', with: user.email
      fill_in 'user_password', with: 'pass'
      click_button I18n.t('helpers.buttons.sign_in')
      expect(page).not_to have_css('.alert.alert-danger')
      expect(page.current_path).to eq root_path
    end

    it 'should authorize the correct user by username' do
      user = FactoryGirl.create :user
      visit new_user_session_path
      fill_in 'user_login', with: user.username
      fill_in 'user_password', with: 'pass'
      click_button I18n.t('helpers.buttons.sign_in')
      expect(page).not_to have_css('.alert.alert-danger')
      expect(page.current_path).to eq root_path
    end
  end

  describe 'sign_up' do
    context 'should prohibit creating user with any incorrect fields:' do
      it 'email' do
        visit new_user_registration_path
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_email.has-error')

        fill_in 'user_email', with: 'wrong email'
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_email.has-error')

        fill_in 'user_email', with: Faker::Internet.safe_email
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).not_to have_css('.user_email.has-error')
      end

      it 'login' do
        visit new_user_registration_path
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_username.has-error')

        fill_in 'user_username', with: 'wrong@username'
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_username.has-error')

        fill_in 'user_username', with: Faker::Internet.user_name
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).not_to have_css('.user_username.has-error')
      end

      it 'password' do
        visit new_user_registration_path
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_password.has-error')

        fill_in 'user_password', with: 'pass'
        fill_in 'user_password_confirmation', with: 'another pass'
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).to have_css('.user_password_confirmation.has-error')

        fill_in 'user_password', with: 'pass'
        fill_in 'user_password_confirmation', with: 'pass'
        click_button I18n.t('helpers.buttons.sign_up')
        expect(page).not_to have_css('.user_password_confirmation.has-error, .user_password.has-error')
      end
    end

    it 'should create a new user' do
      visit new_user_registration_path
      fill_in 'user_email', with: Faker::Internet.safe_email
      fill_in 'user_username', with: Faker::Internet.user_name
      fill_in 'user_password', with: 'pass'
      fill_in 'user_password_confirmation', with: 'pass'
      click_button I18n.t('helpers.buttons.sign_up')
      expect(page).not_to have_css('.alert.alert-danger')
      expect(page.current_path).to eq root_path
    end
  end
end
