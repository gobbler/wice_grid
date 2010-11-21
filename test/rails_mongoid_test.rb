require File.join(File.dirname(__FILE__), '/spec_helper')

describe UsersController do
  include Capybara
  
  context "3 users" do
    before(:each) do
      @aa = User.make(:first_name => 'aabbcc')
      @bb = User.make(:first_name => 'bbccdd')
      @cc = User.make(:first_name => 'ccddee')
      visit '/users'
    end
    
    it "should render grid as table" do
      page.should have_selector('table tr')
    end

    it "should be possible to sort it by clicking titles" do
      page.should_not have_selector '.asc'
      page.should_not have_selector '.desc'
      
      click_link 'First Name'
      page.should have_selector '.asc'
      first_name_column = all('td[1]').map(&:text)
      first_name_column.should == ["aabbcc", "bbccdd", "ccddee"]
      
      click_link 'First Name'
      page.should have_selector '.desc'
      first_name_column = all('td[1]').map(&:text)
      first_name_column.should == ["ccddee", "bbccdd", "aabbcc"]
    end
end
  
end  

