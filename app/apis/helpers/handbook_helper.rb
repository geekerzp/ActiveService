#encoding: utf-8
#
# 图鉴
#
module HandbookHelper
  #
  # 获取用户的图鉴信息
  #
  def get_handbook
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    #获取弟子图鉴
    disciples_handbook = Handbook.get_handbook_by_type(user.id, 1)

    #获取装备图鉴
    equipment_handbook = Handbook.get_handbook_by_type(user.id, 2)

    #获取功夫图鉴
    gongfu_handbook = Handbook.get_handbook_by_type(user.id, 3)

    handbook_hash = {}
    handbook_hash[:disciples] = disciples_handbook
    handbook_hash[:equipment] = equipment_handbook
    handbook_hash[:gongfu] = gongfu_handbook

    render_result(ResultCode::OK, handbook_hash)
  end

  #
  # 设置用户的图鉴信息
  #
  def set_handbook
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    disciples_handbook = params[:disciples]
    equipment_handbook = params[:equipment]
    gongfu_handbook = params[:gongfu]

    if disciples_handbook.nil? || !disciples_handbook.kind_of?(Array) \
    || equipment_handbook.nil? || !equipment_handbook.kind_of?(Array) \
    || gongfu_handbook.nil? || !gongfu_handbook.kind_of?(Array)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
    end

    disciples_handbook.each() do |disciple|
      if disciple[:id].nil? || disciple[:id].to_s.length < 0 || disciple[:type].nil? || disciple[:type].to_i < 0
        return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
      end
      Handbook.add(user.id.to_i, 1, disciple[:id].to_s, disciple[:type].to_i)
    end

    equipment_handbook.each() do |equipment|
      if equipment[:id].nil? || equipment[:id].to_s.length < 0 || equipment[:type].nil? || equipment[:type].to_i < 0
        return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
      end
      Handbook.add(user.id.to_i, 2, equipment[:id].to_s, equipment[:type].to_i)
    end

    gongfu_handbook.each() do |gongfu|
      if gongfu[:id].nil? || gongfu[:id].to_s.length < 0 || gongfu[:type].nil? || gongfu[:type].to_i < 0
        return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
      end
      Handbook.add(user.id.to_i, 3, gongfu[:id].to_s, gongfu[:type].to_i)
    end

    render_result(ResultCode::OK, {})
  end
end