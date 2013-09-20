#
# 接口返回码
#
class ResultCode
  OK                        = 1000 # 成功
  ERROR                     = 1001 # 未知错误
  INVALID_SESSION_KEY       = 1002 # 非法会话key
  INVALID_PARAMETERS        = 1003 # 非法参数

  REGISTERED_USERNAME       = 2011 # 已注册用户名
  INVALID_USERNAME          = 2012 # 用户名格式不对
  INVALID_USERNAME_PASSWORD = 2021 # 用户名或密码错误
  USER_LOCKED               = 2022 # 用户被锁定
  NO_SUCH_USER              = 2023 # 没有这个用户

  ALREADY_FRIENDS           = 3001 # 已经是好友了
  ALREADY_APPLIED           = 3002 # 已经申请好友了
  ALREADY_FOLLOWS           = 3003 # 已经关注过了
  BEYOND_FRIEND_LIMIT       = 3004 # 超过好友数量上限
  BEYOND_FOLLOW_LIMIT       = 3005 # 超过关注数量上限

  NO_GIFTBAG_PURCHASE_RECORDER_FOUND = 4001 # 没有找到礼包购买记录

  LUNJIAN_POSITION_CHANGE   = 6031 # 用户在论剑中的排名位置发生变化
  SAVE_FAILED               = 9999 # 保存失败
end