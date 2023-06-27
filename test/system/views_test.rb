require "application_system_test_case"

class ViewsTest < ApplicationSystemTestCase
  setup do
    @view = views(:one)
  end

  test "visiting the index" do
    visit views_url
    assert_selector "h1", text: "Views"
  end

  test "should create view" do
    visit views_url
    click_on "New view"

    click_on "Create View"

    assert_text "View was successfully created"
    click_on "Back"
  end

  test "should update View" do
    visit view_url(@view)
    click_on "Edit this view", match: :first

    click_on "Update View"

    assert_text "View was successfully updated"
    click_on "Back"
  end

  test "should destroy View" do
    visit view_url(@view)
    click_on "Destroy this view", match: :first

    assert_text "View was successfully destroyed"
  end
end
