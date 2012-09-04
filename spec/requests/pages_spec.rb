require 'spec_helper'

describe "Static pages" do
  describe "Home page" do
    it "should have the content 'Sample App'" do
      visit root_path
      page.should have_content('Sample App')
    end
    
    it "should have the right title" do
      visit root_path
      page.should have_selector('title', :text => "Tag It | Home")
    end
  end
end
