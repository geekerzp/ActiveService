require 'test_helper'

class TeamControllerTest < ActionController::TestCase
  test "update_team" do
    session_key = users(:one).session_key
    test_interface(:update_team, {session_key: session_key, team: [1, 2, 3]}, ResultCode::OK)
    test_interface(:update_team, {session_key: session_key, team: [1, 2, 3, 4]}, ResultCode::OK)
    test_interface(:update_team, {session_key: session_key, team: [1, 2, 4, 3]}, ResultCode::OK)
    test_interface(:update_team, {session_key: session_key, team: [1, 2, 3, 4, 5]}, ResultCode::ERROR)
    test_interface(:update_team, {session_key: session_key, team: '[1, 2, 3, 4, 5]'}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_team, {session_key: session_key}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_team, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_team, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_team, nil, ResultCode::INVALID_SESSION_KEY)
  end
end
