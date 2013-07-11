require 'test_helper'

class KapaiControllerTest < ActionController::TestCase
  test "update_disciples" do
    session_key = users(:one).session_key
    params = { session_key: session_key,
               disciples: [
                  {
                      id: 1, level: 10, experience: 1000, grow_blood: 123, grow_attack: 3423, grow_defend: 34234,
                      grow_internal: 34234, equipments:[1], gongfus: [1]
                  },
                  {
                      id: 2, level: 23, experience: 234, grow_blood: 11233, grow_attack: 213, grow_defend: 234,
                      grow_internal: 12, equipments:[1], gongfus: [1]
                  }
               ]}
    test_interface(:update_disciples, params, ResultCode::OK)

    test_interface(:update_disciples, {session_key: session_key, disciples: ''}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_disciples, {session_key: session_key}, ResultCode::INVALID_PARAMETERS)
    test_interface(:update_disciples, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_disciples, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "update_equipments" do
    session_key = users(:one).session_key
    params = { session_key: session_key,
               equipments: [
                  {id: 1, level: 32, grow_strength: 3242.234, position: -1},
                  {id: 2, level: 12, grow_strength: 3242.234, position: -1}]}
    test_interface(:update_equipments, params, ResultCode::OK)

    test_interface(:update_equipments, { session_key: session_key, equipments: '['} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_equipments, { session_key: session_key} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_equipments, { } , ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_equipments, nil , ResultCode::INVALID_SESSION_KEY)
  end

  test "update_gongfus" do
    session_key = users(:one).session_key
    params = { session_key: session_key,
               gongfus: [
                   {id: 1, level: 32, grow_strength: 3242.234, grow_probability: 0.2, experience: 23, position: -1},
                   {id: 3, level: 32, grow_strength: 3242.234, grow_probability: 0.3, experience: 232, position: -1},
                   {id: 2, level: 12, grow_strength: 3242.234, grow_probability: 0.1, experience: 234, position: -1}]}
    test_interface(:update_gongfus, params, ResultCode::OK)

    test_interface(:update_gongfus, { session_key: session_key, equipments: '['} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_gongfus, { session_key: session_key} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_gongfus, { } , ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_gongfus, nil , ResultCode::INVALID_SESSION_KEY)
  end

  test "update_zhangmenjues" do
    session_key = users(:one).session_key
    params = { session_key: session_key,
               zhangmenjues: [
                   {level: 32, score: 342, poli: 234, type: 1},
                   {level: 32, score: 334, poli: 23, type: 2},
                   {level: 32, score: 334, poli: 23, type: 4},
                   {level: 12, score: 324, poli: 24, type: 3}]}
    test_interface(:update_zhangmenjues, params, ResultCode::OK)

    test_interface(:update_zhangmenjues, { session_key: session_key, equipments: '['} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_zhangmenjues, { session_key: session_key} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_zhangmenjues, { } , ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_zhangmenjues, nil , ResultCode::INVALID_SESSION_KEY)

    params = { session_key: session_key, zhangmenjues: [ {level: 12, score: 324, poli: 24, type: 5}]}
    test_interface(:update_zhangmenjues, params, ResultCode::ERROR)
  end

  test "update_souls" do
    session_key = users(:one).session_key
    params = { session_key: session_key,
               souls: [
                   {potential: 32, number: 342, type: 'disciple_0001'},
                   {potential: 32, number: 42, type: 'disciple_0003'},
                   {potential: 32, number: 42, type: 'disciple_0004'},
                   {potential: 12, number: 324, type: 'disciple_0002'}]}
    test_interface(:update_souls, params, ResultCode::OK)
    params = { session_key: session_key,
               souls: [
                   {potential: 32, number: 342, type: 'disciple_0001'},
                   {potential: 32, number: 42, type: 'disciple_0003'},
                   {potential: 32, number: 0, type: 'disciple_0004'},
                   {potential: 12, number: 0, type: 'disciple_0002'}]}
    test_interface(:update_souls, params, ResultCode::OK)

    test_interface(:update_souls, { session_key: session_key, equipments: '['} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_souls, { session_key: session_key} , ResultCode::INVALID_PARAMETERS)
    test_interface(:update_souls, { } , ResultCode::INVALID_SESSION_KEY)
    test_interface(:update_souls, nil , ResultCode::INVALID_SESSION_KEY)
  end

  test "create_gongfu" do
    session_key = users(:one).session_key
    test_interface(:create_gongfu, {session_key: session_key, type: "gongfu_4001"}, ResultCode::OK)
    test_interface(:create_gongfu, {session_key: session_key}, ResultCode::ERROR)
    test_interface(:create_gongfu, {session_key: session_key, type: "gongfu_4001"}, ResultCode::OK)
    test_interface(:create_gongfu, {session_key: session_key, type: "gongfu_4001"}, ResultCode::OK)
    test_interface(:create_gongfu, {session_key: 'session_key', type: "gongfu_4001"}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:create_gongfu, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:create_gongfu, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "create_equipment" do
    session_key = users(:one).session_key
    test_interface(:create_equipment, {session_key: session_key, type: "equipement_weapon_4001"}, ResultCode::OK)
    test_interface(:create_equipment, {session_key: session_key}, ResultCode::ERROR)
    test_interface(:create_equipment, {session_key: session_key, type: "equipement_weapon_4001"}, ResultCode::OK)
    test_interface(:create_equipment, {session_key: session_key, type: "equipement_weapon_4001"}, ResultCode::OK)
    test_interface(:create_equipment, {session_key: 'session_key',type: "equipement_weapon_4001"},
                   ResultCode::INVALID_SESSION_KEY)
    test_interface(:create_equipment, {}, ResultCode::INVALID_SESSION_KEY)
    test_interface(:create_equipment, nil, ResultCode::INVALID_SESSION_KEY)
  end

  test "create_disciple" do
    session_key = users(:one).session_key
    params = { session_key: session_key, type: "disciple_4108"}
    test_interface(:create_disciple, params, ResultCode::OK)
    params = { session_key: session_key, type: "disciple_4108"}
    test_interface(:create_disciple, params, ResultCode::ERROR)

    params = { session_key: session_key, type: "disciple_4107"}
    test_interface(:create_disciple, params, ResultCode::OK)


    test_interface(:create_disciple, { session_key: session_key} , ResultCode::ERROR)
    test_interface(:create_disciple, { } , ResultCode::INVALID_SESSION_KEY)
    test_interface(:create_disciple, nil , ResultCode::INVALID_SESSION_KEY)
  end
end
