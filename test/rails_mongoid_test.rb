require File.join(File.dirname(__FILE__), '/spec_helper')

describe UsersController do
  include Capybara::DSL

  context "3 users" do
    before(:each) do
      @aa = User.make(:first_name => 'aabbcc', :year => Time.parse('1980-01-01'), :archived => true)
      @bb = User.make(:first_name => 'bbccdd', :year => Time.parse('1990-01-01'), :last_login => Time.parse('2010-01-01 4pm'))
      @cc = User.make(:first_name => 'ccddee', :year => Time.parse('2000-01-01'), :computers_number => 3)
      @c1 = Computer.make(:user_id => @aa.id, :name => "aa_host_1")
      @c2 = Computer.make(:user_id => @aa.id, :name => "aa_host_2")
    end
    
    it "should render grid as table" do
      UsersController.columns do |grid|
        grid.column :column_name => 'First Name', :attribute_name => 'first_name' 
      end
      visit '/users'
      page.should have_selector('table.wice_grid tr')
    end

    it "should be possible to sort it by clicking titles" do
      UsersController.columns do |grid|
        grid.column :column_name => 'First Name', :attribute_name => 'first_name' 
      end
      visit '/users'
      page.should_not have_selector '.asc'
      page.should_not have_selector '.desc'
      
      click_link 'First Name'
      page.should have_selector '.asc'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.should == ["aabbcc", "bbccdd", "ccddee"]
      
      click_link 'First Name'
      page.should have_selector '.desc'
      
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.should == ["ccddee", "bbccdd", "aabbcc"]
    end

    it "should be possible to see String filters and use them" do
      UsersController.columns do |grid|
        grid.column :column_name => 'First Name', :attribute_name => 'first_name'
      end
      visit '/users'
      fill_in "grid[f][first_name]", :with => 'bb'
      visit '/users?grid[f][first_name][v]=bb&grid[f][first_name][n]=bb'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 2
    end

    it "should be possible to see Date filters and use them" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'DOB', :attribute_name => 'year'
      end
      visit URI.escape('/users?grid[f][year][fr]=1985-01-01&grid[f][year][to]=2005-01-01')
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 2
    end

    it "should be possible to see Time filters and use them" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'Last Login', :attribute_name => 'last_login'
      end
      visit URI.escape('/users?grid[f][last_login][fr]=2010-01-01 01:00&grid[f][last_login][to]=2010-01-03 01:00')
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 1
    end

    it "should be possible to see Integer filters and use them" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'Computers Number', :attribute_name => 'computers_number'
      end
      visit '/users?grid[f][computers_number][fr]=2&grid[f][computers_number][to]=5'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 1
    end

    it "should be possible to use K,M,G,KB,MB,GB in Integer filters" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'Storage Limit', :attribute_name => 'storage_limit'
      end
      
      visit '/users?grid[f][storage_limit][fr]=1K&grid[f][storage_limit][to]=5K'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 0
      
      visit '/users?grid[f][storage_limit][fr]=1Mb&grid[f][storage_limit][to]=200M'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 0

      visit '/users?grid[f][storage_limit][fr]=500mb&grid[f][storage_limit][to]=20G'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 3
    end

    it "should be possible to use '/' for String fields to indicate regexp" do
      UsersController.columns do |grid|
        grid.column :column_name => 'First Name', :attribute_name => 'first_name' 
      end
      visit '/users'
      filter_string = '/c.*e'
      fill_in "grid[f][first_name]", :with => filter_string
      visit "/users?grid[f][first_name][v]=#{URI.escape(filter_string)}&grid[f][first_name][n]=#{URI.escape(filter_string)}"
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 1
      
      filter_string = 'c.*e'
      fill_in "grid[f][first_name]", :with => filter_string
      visit "/users?grid[f][first_name][v]=#{URI.escape(filter_string)}&grid[f][first_name][n]=#{URI.escape(filter_string)}"
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 0
    end
    
    it "should be possible to see Boolean filters and use them" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'Archived', :attribute_name => 'archived'
      end
      visit '/users?grid[f][archived][]=f'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.size.should == 2
    end

    it "should be possible to see aggregated association data" do
      UsersController.columns do |grid| 
        grid.column :column_name => 'Computers Number' do |user|
          Computer.where(:user_id => user.id).count
        end
      end
      visit '/users'
      first_name_column = all('tbody td[1]').map(&:text)
      first_name_column.map(&:to_i).sum.should == 2
    end
  end
end
