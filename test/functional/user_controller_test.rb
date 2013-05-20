#encoding: utf-8
require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "register" do
    test_interface(:register, {username: 'kernelhcy', password: '123456'}, ResultCode::OK)
    test_interface(:register, {username: 'kernelhcy', password: '123456'}, ResultCode::REGISTERED_USERNAME)
    test_interface(:register, {username: '', password: '123456'}, ResultCode::INVALID_USERNAME)
    test_interface(:register, {}, ResultCode::INVALID_USERNAME)
    test_interface(:register, nil, ResultCode::INVALID_USERNAME)
  end

  test "login" do
    test_interface(:login, {username: 'user1', password: 'user1'}, ResultCode::OK)
    test_interface(:login, {username: 'user1', password: 'password'}, ResultCode::INVALID_USERNAME_PASSWORD)
    test_interface(:login, {username: 'user2', password: 'user1'}, ResultCode::INVALID_USERNAME_PASSWORD)
    test_interface(:login, {username: 'user2'}, ResultCode::INVALID_USERNAME_PASSWORD)
    test_interface(:login, {}, ResultCode::INVALID_USERNAME_PASSWORD)
    test_interface(:login, nil, ResultCode::INVALID_USERNAME_PASSWORD)
  end

  test "get_user_info" do
    session_key = users(:one).session_key
    test_interface(:get_user_info, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_user_info, {session_key: session_key, user_id: 1}, ResultCode::OK)
    test_interface(:get_user_info, {session_key: session_key, user_id: -1}, ResultCode::NO_SUCH_USER)
    test_interface(:get_user_info, {session_key: session_key, user_id: 11}, ResultCode::NO_SUCH_USER)
    test_interface(:get_user_info, {session_key: 'session_key', user_id: 1}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_user_info, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_user_info, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "update_user_info" do
    session_key = users(:one).session_key
    params = {session_key: session_key, name: "苏北", vip_level: 10, level: 23, prestige: 23, gold: 23,
              silver: 23, power: 43, experience: 300, sprite: 100, lunjian_time: 20}
    test_interface(:update_user_info, params, ResultCode::OK)
  end

  test "update_goods" do
    session_key = users(:one).session_key
    params = {session_key: session_key, goods: [
        {type: 1, number: 10}, {type: 2, number: 2}
    ]}
    test_interface(:update_goods, params, ResultCode::OK)
  end

  test "get_random_zhangmen_name" do
    session_key = users(:one).session_key
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_random_zhangmen_name, {session_key: session_key}, ResultCode::OK)
  end
end
