class Admins < ActiveRecord::Base
  attr_accessible :password, :username
  validates :username, :uniqueness => true

  #
  # 管理员登录
  #
  # @param [String] username 用户名
  # @param [String] password 密码
  # @return [String, Admin]  会话key和管理员实例
  def self.login(username, password)
    admin = Admins.find_by_username_and_password(username, Digest::SHA2.hexdigest(password).to_s)
    #admin = Admins.find_by_username_and_password(username, password)
    if admin.nil?
      return nil, nil
    end
    session_key = admin.create_session_key
    if session_key.nil?
      return nil, nil
    end

    # 记录登录
    #admin_login_recorder = AdminLoginRecorder.new
    #admin_login_recorder.admin_id = admin.id
    #admin_login_recorder.login_ip = ip
    #admin_login_recorder.login_time = Time.now
    #admin_login_recorder.action = AdminLoginRecorder::LOGIN_ACTION
    #admin_login_recorder.save

    return session_key, admin
  end

  #
  # 登出
  #
  # @param [String] session_key 回话key
  def self.logout(session_key)
    admin = Admins.find_by_session_key(session_key)
    if admin.nil?
      return false
    end

    return false unless admin.update_attribute(:session_key, Digest::SHA2.hexdigest("#{rand(1000000)}").to_s)

    ## 记录登出
    #admin_login_recorder = AdminLoginRecorder.new
    #admin_login_recorder.admin_id = admin.id
    #admin_login_recorder.login_ip = ip
    #admin_login_recorder.login_time = Time.now
    #admin_login_recorder.action = AdminLoginRecorder::LOGOUT_ACTION
    #admin_login_recorder.save
    true
  end

  #
  # 构造回话key
  #
  def create_session_key
    tmp = "#{Time.now.to_s}"
    tmp << self.username
    tmp << self.password
    tmp << "#{rand(100000)}"
    session_key = Digest::SHA2.hexdigest(tmp).to_s
    unless self.update_attribute(:session_key, session_key)
      return nil
    end
    session_key
  end
end
