require 'test_helper'

class QiyuControllerTest < ActionController::TestCase
  test "get_jiaohuaji_detail" do
    session_key = users(:one).session_key
    test_interface(:get_jiaohuaji_detail, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_jiaohuaji_detail, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_jiaohuaji_detail, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_jiaohuaji_detail, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "eat_jiaohuaji" do
    session_key = users(:one).session_key
    test_interface(:eat_jiaohuaji, {session_key: session_key, type: 2}, ResultCode::OK)
    test_interface(:eat_jiaohuaji, {session_key: session_key, type: 2}, ResultCode::ERROR)
    test_interface(:eat_jiaohuaji, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:eat_jiaohuaji, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:eat_jiaohuaji, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "get_canbai_recorders" do
    session_key = users(:one).session_key
    test_interface(:get_canbai_recorders, {session_key: session_key}, ResultCode::OK)
    test_interface(:get_canbai_recorders, {session_key: 'session_key_10'}, ResultCode::OK)
    test_interface(:get_canbai_recorders, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_canbai_recorders, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_canbai_recorders, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "canbai" do
    session_key = users(:one).session_key
    #100.times{|i| test_interface(:canbai, {session_key: session_key}, ResultCode::OK)}
    test_interface(:canbai, {session_key: session_key}, ResultCode::OK)

    test_interface(:canbai, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:canbai, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:canbai, nil, ResultCode::INVALID_SESSION_KEY)
  end
end
