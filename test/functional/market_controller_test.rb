#encoding: utf-8
require 'test_helper'

class MarketControllerTest < ActionController::TestCase
  test "obtain_disciple" do
    session_key = users(:one).session_key
    test_interface(:obtain_disciple, {session_key: session_key, type: 3}, ResultCode::OK)
    test_interface(:obtain_disciple, {session_key: session_key, type: 3}, ResultCode::OK)
    test_interface(:obtain_disciple, {session_key: session_key, type: 1}, ResultCode::OK)
    100.times() {|i| test_interface(:obtain_disciple, {session_key: session_key, type: 2}, ResultCode::OK)}
    test_interface(:obtain_disciple, {session_key: session_key}, ResultCode::OK)
    test_interface(:obtain_disciple, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:obtain_disciple, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:obtain_disciple, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "buy_goods" do
    session_key = users(:one).session_key
    test_interface(:buy_goods, {session_key: session_key, name: URI.encode('聚宝木箱'), number: 1}, ResultCode::OK)
    test_interface(:buy_goods, {session_key: session_key, name: URI.encode('聚宝金鼎'), number: 1}, ResultCode::OK)
    test_interface(:buy_goods, {session_key: session_key, name: URI.encode('聚宝金鼎'), number: 100}, ResultCode::ERROR)
    test_interface(:buy_goods, {session_key: session_key, name: URI.encode('聚宝金鼎')}, ResultCode::OK)
    test_interface(:buy_goods, {session_key: session_key }, ResultCode::ERROR)

    test_interface(:buy_goods, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:buy_goods, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:buy_goods, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "get_my_gift_bags" do
    session_key = users(:one).session_key
    test_interface(:get_my_gift_bags, {session_key: session_key}, ResultCode::OK)

    test_interface(:get_my_gift_bags, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_my_gift_bags, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:get_my_gift_bags, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "buy_gift_bag" do
    session_key = users(:one).session_key
    test_interface(:buy_gift_bag, {session_key: session_key, name: URI.encode('Vip3 尊享礼包'), number: 1}, ResultCode::OK)
    test_interface(:buy_gift_bag, {session_key: session_key, name: URI.encode('Vip1 尊享礼包'), number: 100}, ResultCode::ERROR)
    test_interface(:buy_gift_bag, {session_key: session_key, name: URI.encode('Vip2 尊享礼包')}, ResultCode::OK)
    test_interface(:buy_gift_bag, {session_key: session_key }, ResultCode::ERROR)

    test_interface(:buy_gift_bag, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:buy_gift_bag, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:buy_gift_bag, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "open_gift_bag" do
    session_key = users(:one).session_key
    test_interface(:open_gift_bag, {session_key: session_key, id: 1}, ResultCode::OK)
    test_interface(:open_gift_bag, {session_key: session_key, id: 2}, ResultCode::OK)
    test_interface(:open_gift_bag, {session_key: session_key }, ResultCode::ERROR)

    test_interface(:open_gift_bag, {session_key: 'session_key'}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:open_gift_bag, { }, ResultCode::INVALID_SESSION_KEY)
    test_interface(:open_gift_bag, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "get_obtain_disciple_recorders" do
    session_key = users(:one).session_key
    test_interface(:get_obtain_disciple_recorders, {session_key: session_key}, ResultCode::OK)
  end
end
