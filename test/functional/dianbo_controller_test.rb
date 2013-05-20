require 'test_helper'

class DianboControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'create_new_dianbo' do
    session_key = users(:one).session_key
    test_interface(:create_new_dianbo, {session_key: session_key, type: 1}, 1000)
    test_interface(:create_new_dianbo, {session_key:'session_key', type: 1}, 1002)
    test_interface(:create_new_dianbo, {}, 1002)
    test_interface(:create_new_dianbo, {session_key:session_key, type: 10}, 1003)
  end
  test 'use_dianbo' do
    session_key = users(:one).session_key
    test_interface(:use_dianbo, {session_key:session_key, type: 1}, 1000)
    test_interface(:use_dianbo, {session_key:'session_key', type: 1}, 1002)
    test_interface(:use_dianbo, {}, 1002)
    test_interface(:use_dianbo, {session_key:session_key, type: 10}, 1003)
  end
  test 'get_unused_dianbos' do
    session_key = users(:one).session_key
    test_interface(:get_unused_dianbos, {session_key:session_key}, 1000)
    test_interface(:get_unused_dianbos, {session_key:'session_key'}, 1002)
    test_interface(:get_unused_dianbos, {}, 1002)
  end
end
