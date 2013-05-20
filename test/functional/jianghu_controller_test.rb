require 'test_helper'

class JianghuControllerTest < ActionController::TestCase

  test "get_jianghu_recorders" do
    session_key = users(:one).session_key
    test_interface(:get_jianghu_recorders, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_jianghu_recorders, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_jianghu_recorders, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_jianghu_recorders, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "update_recorder" do
    session_key = users(:one).session_key
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 2, star: 2, is_finish: 1}, ResultCode::OK)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 2, star: 2, is_finish: 1}, ResultCode::OK)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 2, star: 3, is_finish: 1}, ResultCode::OK)

    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: 1, is_finish: 0}, ResultCode::OK)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: 1, is_finish: 0}, ResultCode::OK)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: 1, is_finish: 0}, ResultCode::OK)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: 2, is_finish: 1}, ResultCode::OK)

    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: 1, is_finish: -1}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_recorder, {session_key: session_key, scene_id: -1,
                                      item_id: 3, star: 1, is_finish: 1}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: -3, star: 1, is_finish: 1}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_recorder, {session_key: session_key, scene_id: 1,
                                      item_id: 3, star: -1, is_finish: 1}, ResultCode::INVALID_PARAMETERS)

    test_interface(:update_recorder, {session_key: session_key }, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_recorder, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_recorder, nil, ResultCode::INVALID_SESSION_KEY)
  end
end
