#coding : utf-8
#
# 后台任务
#
namespace :bgtask do
  #
  # 恢复用户的体力
  # 每20分钟恢复一点
  # cron脚本：
  # */20 * * * * cd /home/zhangmenren/server && /opt/ruby/bin/ruby /opt/ruby/bin/rake bgtask:reset_user_power
  #
  desc '恢复用户的体力'
  task(:reset_user_power => :environment) do
    User.find_each(batch_size: 1000) do |u|
      if u.power < 30
        u.power += 1
        u.save
      end
    end
  end

  #
  # 恢复用户的元气
  # 每30分钟恢复一点
  # cron脚本：
  # */30 * * * * cd /home/zhangmenren/server && /opt/ruby/bin/ruby /opt/ruby/bin/rake bgtask:reset_user_sprite
  #
  desc '恢复用户的元气'
  task(:reset_user_sprite => :environment) do
    User.find_each(batch_size: 1000) do |u|
      if u.sprite < 12
        u.sprite += 1
        u.save
      end
    end
  end

  #
  # 重置用户的论剑次数
  # 每天0点重置
  # cron脚本：
  # 0 0 * * * cd /home/zhangmenren/server && /opt/ruby/bin/ruby /opt/ruby/bin/rake bgtask:reset_user_lunjian_time
  #
  desc '重置用户的论剑'
  task(:reset_user_lunjian_time => :environment) do
    User.find_each(batch_size: 1000) do |u|
      lp = LunjianPosition.find_by_user_id(u.id)
      unless lp.nil?
        if u.vip_level == 0
          lp.left_time = 5
        else
          lp.left_time = ZhangmenrenConfig.instance.vip_config[u.vip_level.to_s]['lunjian_time_per_day'].to_i
        end
        lp.save
      end
    end
  end

  #
  # 增加用户的论剑积分
  # 每10分钟，运行一次
  # cron脚本：
  # */10 * * * * cd /home/zhangmenren/server && /opt/ruby/bin/ruby /opt/ruby/bin/rake bgtask:add_user_lunjian_score
  #
  desc '增加用户的论剑积分'
  task(:add_user_lunjian_score => :environment) do
    score_array = ZhangmenrenConfig.instance.lunjian_config['score_array']
    User.find_each(batch_size: 1000) do |u|
      lp = LunjianPosition.find_by_user_id(u.id)
      unless lp.nil?
        if lp.position <= score_array.length
          lp.score += score_array[lp.position - 1].to_i
        else
          lp.score += (300.to_f / Math.sqrt(lp.position.to_f)).to_i;
        end
        lp.save
      end
    end
  end

  #
  # 重置用户江湖挑战次数
  # 每天0点重置
  # cron脚本：
  # 0 0 * * * cd /home/zhangmenren/server && /opt/ruby/bin/ruby /opt/ruby/bin/rake bgtask:reset_user_jianghu_time
  #
  desc '重置用户江湖挑战次数'
  task(:reset_user_jianghu_time => :environment) do
    JianghuRecorder.find_each(batch_size: 1000) do |r|
      r.fight_time = 0
      r.save
    end
  end
end