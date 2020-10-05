require 'test_helper'

class RoutingKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get routing_keys_new_url
    assert_response :success
  end

  test "should get create" do
    get routing_keys_create_url
    assert_response :success
  end

  test "should get verify" do
    get routing_keys_verify_url
    assert_response :success
  end

end
