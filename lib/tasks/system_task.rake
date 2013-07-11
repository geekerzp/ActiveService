#coding : utf-8
#
# 系统任务
#
namespace :system do
  #
  # 系统维护后给用户发消息并进行补偿
  # 执行命令 /opt/ruby/bin/ruby /opt/ruby/bin/rake system:send_system_message
  #
  desc '发送系统消息'
  task(:send_system_message => :environment) do
    system_message = '今天服务器维护，送叫花鸡3个，100000白银，祝愿大家玩的开心'
    reward_type = '1001' # 例子
    User.find_each(batch_size: 1000) do |user|
      if user.npc_or_not == 0 # 不是npc的用户会收到奖励
        system_reward_record = SystemRewardRecorder.new
        system_reward_record.system_message = system_message
        system_reward_record.reward_type = reward_type
        system_reward_record.user_id = user.id
        system_reward_record.receive_or_not = SystemRewardRecorder::NOT_RECEIVED
        system_reward_record.save
      end
    end
  end

  #
  # 初始化系统后，根据npc_config.json进行npc数据初始化，存入数据库
  # 执行命令 /opt/ruby/bin/ruby /opt/ruby/bin/rake system:init_npc
  #
  desc '初始化npc'
  task(:init_npc => :environment) do
    # 解析npc配置
    npc_config_path = "#{Rails.root}/config/configurations/npc_config.json"
    npc_config_content = ''
    File.open(npc_config_path, 'r'){|f| npc_config_content = f.read }
    npc_config_array = JSON.parse(npc_config_content)
    puts ("npc配置信息: \n#{JSON.pretty_generate(npc_config_array).to_s}")

    lunjian_rank = 1 # 论剑排位从1开始
    npc_config_array.each() do |npc|
      puts "position:#{lunjian_rank}"
      # 导入npc基本信息
      user = User.new
      user.name = npc['name'].to_s
      user.level = npc['level'].to_i
      user.username = npc['id'].to_s
      user.password = npc['id'].to_s
      # 区分npc和普通用户
      user.npc_or_not = 1

      if user.save
        puts 'user save success'
      else
        puts 'user save failed'
      end
      puts ("user信息: \n#{user.to_s}")

      team_position = 0 # 布阵排位从0开始
                        # 导入阵容信息
      team_array = npc['team']
      team_array.each() do |member|
        # 记录弟子信息
        disciple = Disciple.new
        disciple.d_type = member['id']
        disciple.level = member['level']
        disciple.user_id = user.id
        disciple.save

        # 记录弟子阵容排位信息
        team_member = TeamMember.new
        team_member.user_id = user.id
        team_member.disciple_id = disciple.id
        team_member.position = team_position
        team_member.save

        team_position = team_position + 1
      end

      # 添加论剑排名记录
      lunjian_position = LunjianPosition.new
      lunjian_position.user_id = user.id
      lunjian_position.position = lunjian_rank
      lunjian_position.left_time = 0
      lunjian_position.score = 0
      lunjian_position.save

      lunjian_rank = lunjian_rank + 1
    end
  end

end
