require 'rails_helper'

RSpec.feature 'tags', type: :feature, js: true do
  let(:patches) do
    [
      FactoryGirl.create(:patch, name: 'Patch 1', tags: %w(lead cool)),
      FactoryGirl.create(:patch, name: 'Patch 2', tags: %w(bass wow)),
      FactoryGirl.create(:patch, name: 'Patch 3', tags: %w(lead scary))
    ]
  end

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    user.patches << patches
    visit root_path
  end

  def perform_around
    VCR.use_cassette('oembed') do
      yield
    end
  end

  around(:each) do |example|
    perform_around(&example)
  end

  scenario 'patch detail page shows tags as links' do
    expect(page.first('.wrapper')).to have_content('#lead')

    click_link 'Patch 1'
    expect(page).to have_link('#lead')

    click_link('#lead')
    expect(page).to have_title('#lead tag | VolcaShare')
    expect(page).to have_content('#lead')
    expect(page).to have_link('Patch 1')
    expect(page).to have_link('Patch 3')
    expect(page).not_to have_link('Patch 2')
  end

  scenario 'patch index page shows tags as links' do
    expect(page.first('.wrapper')).to have_content('#lead')
    expect(page).to have_link('#lead')

    first(:link, '#lead').click
    expect(page).to have_content('#lead')
    expect(page).to have_link('Patch 1')
    expect(page).to have_link('Patch 3')
    expect(page).not_to have_link('Patch 2')
  end

  scenario 'visit a tag page that doesn\'t exist' do
    visit('/tags/show?tag=fake')
    expect(page).to have_content('No patches to show.')
  end
end
