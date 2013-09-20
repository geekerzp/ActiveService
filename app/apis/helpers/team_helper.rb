#encoding:utf-8
module TeamHelper
  #
  # 更新阵容
  #
  def update_team
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    team = params[:team]
    if team.nil? || !team.kind_of?(Array)
      return render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
    end

    re, err_msg = TeamMember.update_team(user, team)
    unless re
      return render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
    end
    render_result(ResultCode::OK, {})
  end

  #
  #获取用户阵容
  #
  def get_team
    re,user= validate_session_key(get_params(params,:session_key))
    return unless re

    team = TeamMember.get_team(user)
    return render_result(ResultCode::OK,{team:team})
  end
end