require 'test_helper'

class CanzhangControllerTest < ActionController::TestCase
  test "get_list" do
    session_key = users(:one).session_key
    test_interface(:get_list, {session_key:session_key, type: 'gongfu_4002_canzhang_1', limit: 3}, ResultCode::OK)
    test_interface(:get_list, {session_key:session_key, type: 'gongfu_4002_canzhang_2', limit: 3}, ResultCode::OK)
    test_interface(:get_list, {session_key:session_key, type: 'gongfu_4002_canzhang_3'}, ResultCode::OK)
    test_interface(:get_list, {session_key:'session_key', type: 'gongfu_4002_canzhang_3'},
                    ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_list, {session_key:session_key, type: '3'}, ResultCode::OK)
    test_interface(:get_list, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_list, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "update_result" do
    session_key = users(:one).session_key
    100.times() do |i|
      test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: -100, is_win: 1},
                     ResultCode::OK)
    end
    test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: -100, is_win: 0},
                   ResultCode::OK)
    test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: 1101, is_win: 1},
                   ResultCode::OK)
    test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: 1101, is_win: 1},
                   ResultCode::OK)
    test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: 1101, is_win: 1},
                   ResultCode::OK)
    test_interface(:update_result, {session_key:session_key, type: 'gongfu_4002_canzhang_1', user_id: 1101, is_win: 0},
                   ResultCode::OK)
  end

  test "get_my_canzhangs" do
    session_key = users(:one).session_key
    test_interface(:get_my_canzhangs, {session_key:session_key}, ResultCode::OK)
  end

  test "update_canzhangs" do
    session_key = users(:one).session_key
    param = {session_key:session_key, canzhangs: [
        {id: 1, number: 5},
        {id: 2, number: 5},
        {id: 3, number: 5},
        {id: 4, number: 5},
        {id: 5, number: 0},
    ]}
    test_interface(:update_canzhangs, param, ResultCode::OK)
    test_interface(:get_my_canzhangs, {session_key:session_key}, ResultCode::OK)
  end
end
