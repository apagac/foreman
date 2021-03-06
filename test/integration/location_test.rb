require 'test_helper'

class LocationTest < ActionDispatch::IntegrationTest

  def setup
    FactoryGirl.create(:host)
  end

  test "index page" do
    assert_index_page(locations_path,"Locations","New Location")
  end

  # context - has nil hosts
  test "index page has notice if nil hosts" do
    Host.update_all(:location_id => nil)
    visit locations_path
    assert has_selector?("div.alert", :text => "with no location assigned")
  end

  # context - does not nil hosts
  test "index page does not show notice if all hosts" do
    Host.update_all(:location_id => Location.first.id)
    visit locations_path
    assert has_no_selector?("div.alert", :text => "with no location assigned")
  end

  # context - creating when all hosts are assigned
  test "create new page when all hosts are assigned a location" do
    Host.update_all(:location_id => Location.first.id)
    assert has_no_selector?("div.alert", :text => "with no location assigned")
    assert_new_button(locations_path,"New Location",new_location_path)
    fill_in "location_name", :with => "Raleigh"
    assert_submit_button(locations_path)
    assert page.has_link? "Raleigh"
  end

  # content - click Assign All
  test "create new page when some hosts are not assigned a location and click Assign All" do
    assert_new_button(locations_path,"New Location",new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_equal step2_location_path(Location.unscoped.order(:id).last), current_path, "redirect path #{step2_location_path(Location.unscoped.order(:id).last)} was expected but it was #{current_path}"
    click_link "Assign All"
    assert_equal locations_path, current_path, "redirect path #{locations_path} was expected but it was #{current_path}"
    assert page.has_link? "Raleigh"
  end

  # content - click Manually Assign
  test "create new page when some hosts are not assigned a location and click Manually Assign" do
    assert_new_button(locations_path,"New Location",new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_equal step2_location_path(Location.unscoped.order(:id).last), current_path, "redirect path #{step2_location_path(Location.unscoped.order(:id).last)} was expected but it was #{current_path}"
    click_link "Manually Assign"
    assert_equal assign_hosts_location_path(Location.unscoped.order(:id).last), current_path, "redirect path #{assign_hosts_location_path(Location.unscoped.order(:id).last)} was expected but it was #{current_path}"
    assert_submit_button(locations_path, "Assign to Location")
    assert page.has_link? "Raleigh"
  end

  # click Proceed to Edit
  test "create new page when some hosts are and assigned a location and click Proceed to Edit" do
    assert_new_button(locations_path,"New Location",new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_equal step2_location_path(Location.unscoped.order(:id).last), current_path, "redirect path #{step2_location_path(Location.unscoped.order(:id).last)} was expected but it was #{current_path}"
    click_link "Proceed to Edit"
    assert_equal edit_location_path(Location.unscoped.order(:id).last), current_path, "redirect path #{edit_location_path(Location.unscoped.order(:id).last)} was expected but it was #{current_path}"
    assert page.has_selector?('h1', :text => "Edit"), "Edit was expected in the <h1> tag, but was not found"
  end

  # PENDING
  # test "mismatches report" do
  # end
end
