class TeamController < ApplicationController
  #
  # 更新阵容
  #
  def update_team
    re, user = validate_session_key(get_params(params, :session_key))
    return unless re

    team = params[:team]
    if team.nil? || !team.kind_of?(Array)
      render_result(ResultCode::INVALID_PARAMETERS, {err_msg: URI.encode("invalid parameters")})
      return
    end

    re, err_msg = TeamMember.update_team(user, team)
    unless re
      render_result(ResultCode::ERROR, {err_msg: URI.encode(err_msg)})
      return
    end
    render_result(ResultCode::OK, {})
  end
end
