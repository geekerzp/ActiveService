class DianboController < ApplicationController
  #
  # 创建一个新的奇遇点拨。
  #
  def create_new_dianbo
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    type = params[:type]
    server_time = Time.now
    #点拨类型类表。
    type_list = Dianbo.get_types_list
    unless type_list.include?(type.to_i)
      render_result(ResultCode::INVALID_PARAMETERS, {})
      return
    end
    err_msg = ''
    user_dianbos_number = user.dianbos.count
    if user_dianbos_number >= 7
      render_result(ResultCode::OK, {})
      return
    end
    re, dianbo_info = Dianbo.add_new_dianbo(user, type, server_time)

    if re
      render_result(ResultCode::OK, {dianbo: dianbo_info})
    else
      render_result(ResultCode::ERROR, {err_msg: err_msg})
    end
  end

  #
  # 使用点拨。
  #
  def use_dianbo
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    id = params[:id]
    re = Dianbo.use(id)

    if re
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::ERROR, {})
    end
  end

  #
  # 获取未使用的点拨列表。
  #
  def get_unused_dianbos
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    server_time = Time.now
    #用户的点拨详情列表
    user_dianbos_list = Dianbo.get_user_dianbos(user, server_time)

    render_result(ResultCode::OK, {dianbo:user_dianbos_list})
  end

  #
  # 删除高人点拨
  #
  def delete_dianbo
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    id = params[:id]
    re = Dianbo.delete_dianbo(id)

    if re
      render_result(ResultCode::OK, {})
    else
      render_result(ResultCode::ERROR, {})
    end
  end
end
