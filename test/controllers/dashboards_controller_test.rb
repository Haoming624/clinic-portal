require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get receptionist" do
    get dashboards_receptionist_url
    assert_response :success
  end

  test "should get doctor" do
    get dashboards_doctor_url
    assert_response :success
  end
end
