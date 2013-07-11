require 'test_helper'

class LunjianControllerTest < ActionController::TestCase
  test "get_list" do
    test_interface(:get_list, {session_key: '0a041b9462caa4a31bac3567e0b6e6fd9100787db2ab433d96f6d178cabfce90'},
                   ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_1'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_3'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_5'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_10'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_14'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_30'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_34'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_200'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_210'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_310'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_999'}, ResultCode::OK)
    test_interface(:get_list, {session_key: 'session_key_1200'}, ResultCode::OK)
  end

  test "update_result" do
    test_interface(:update_result, {session_key: 'session_key_10', position: 5, is_win: 1, id: 5}, ResultCode::OK)
    test_interface(:update_result, {session_key: 'session_key_12', position: 5, is_win: 1, id: 5},
                   ResultCode::LUNJIAN_POSITION_CHANGE)
    test_interface(:update_result, {session_key: 'session_key_5', position: 2, is_win: 0, id: 2}, ResultCode::OK)
  end

  test "refresh_recorder" do
    test_interface(:refresh_recorder, {session_key: 'session_key_10'}, ResultCode::OK)
    test_interface(:refresh_recorder, {session_key: 'session_key_12'}, ResultCode::OK)
    test_interface(:refresh_recorder, {session_key: 'session_key_5'}, ResultCode::OK)
    test_interface(:refresh_recorder, {session_key: 'session_key_1300'}, ResultCode::ERROR)
  end

  test "get_reward_recorders" do
    session_key = users(:one).session_key
    test_interface(:get_reward_recorders, {session_key: session_key}, ResultCode::OK)
  end

  test "add_reward_recorder" do
    session_key = users(:one).session_key
    test_interface(:add_reward_recorder, {session_key: session_key, position: 1, reward: 1}, ResultCode::OK)
    test_interface(:add_reward_recorder, {session_key: session_key, position: 1, reward: 1}, ResultCode::ERROR)
    test_interface(:add_reward_recorder, {session_key: session_key, position: 1000, reward: 1}, ResultCode::OK)
    test_interface(:add_reward_recorder, {session_key: session_key, position: 10000, reward: 1}, ResultCode::ERROR)
    test_interface(:add_reward_recorder, {session_key: session_key, position: 10000, reward: -1}, ResultCode::ERROR)
    test_interface(:add_reward_recorder, {session_key: session_key, position: -1, reward: 1}, ResultCode::ERROR)
  end
end
