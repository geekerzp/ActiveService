# vi: set fileencoding=utf-8 :
class Trigger 
  DISCIPLE_PAT  = /^disciple_(\d)\d{3}$/
  EQUIPMENT_PAT = /^equipment_\w+_(\d)\d{3}$/
  GONGFU_PAT    = /^gongfu_(\d)\d{3}$/


  class << self 
    # 招降新武将（仅限甲级，乙级武将）
    # Disciple.create_disciple
    def rule_1(user, disciple) 
      if disciple.d_type =~ DISCIPLE_PAT
        message = case $1
                  when '3' then "恭喜掌门#{user.name}获得甲级武将"
                  when '2' then "恭喜掌门#{user.name}获得乙级武将"
                  else nil 
                  end 
      end 

      return if message.nil?

      produce_message(message, '招降新武将事件触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    # 武将突破（仅限甲级，乙级武将，每日第一次）
    # Disciple.update_disciples
    def rule_2(user, disciple)
      return unless disciple.d_type =~ DISCIPLE_PAT

      message = "恭喜掌门#{user.name}武将成功突破"
      produce_message(message, '武将突破事件触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    # 开宝箱获得道具（仅限甲级，乙级武功和装备）
    # Equipment.create_equipment
    # Gongfu.create_gongfu
    def rule_3(user, type)
      if type =~ EQUIPMENT_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}开启宝箱，获得甲级装备"
                  when '3' then "恭喜掌门#{user.name}开启宝箱，获得乙级装备"
                  else nil 
                  end 
      end 

      if type =~ GONGFU_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}开启宝箱，获得甲级功夫"
                  when '3' then "恭喜掌门#{user.name}开启宝箱，获得乙级功夫"
                  else nil
                  end 
      end 

      return if message.nil?

      produce_message(message, '开启宝箱事件触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    # 残章收集完全之后获得新武功
    # Gongfu.create
    def rule_4(user, type)
      if type =~ GONGFU_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}合成残章获得甲级武功"
                  when '3' then "恭喜掌门#{user.name}合成残章获得乙级武功"
                  else nil 
                  end 
      end 

      return if message.nil?
      produce_message(message, '收集残章合成武功时间触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    # 武功装备升级强化（仅限甲级，乙级装备，每日第一次）
    # Gongfu.update_gongfus
    # Equipment.update_equipments
    def rule_5(user, type)
      if type =~ EQUIPMENT_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}成功强化甲级装备"
                  when '3' then "恭喜掌门#{user.name}成功强化乙级装备"
                  else nil 
                  end 
      end 

      if type =~ GONGFU_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}成功强化甲级功夫"
                  when '3' then "恭喜掌门#{user.name}成功强化乙级功夫"
                  else nil
                  end 
      end

      return if message.nil?
  
      produce_message(message, '武功装备升级强化事件触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    # 参加活动获得奖励（获得甲乙级装备，10000以上银两，50以上元宝）
    # Equipment.create_equipment
    # User.update_info 
    # User.update_gold 
    # User.update_gold_power
    # User.update-gold_sprite
    def rule_6(user, type = nil, money = {})
      if type =~ EQUIPMENT_PAT
        message = case $1
                  when '4' then "恭喜掌门#{user.name}获得甲级功夫"
                  when '3' then "恭喜掌门#{user.name}获得乙级功夫"
                  else nil 
                  end 
      end 

      message = "恭喜掌门#{user.name}获得10000银子奖励" if money[:sliver] >= 10000
      message = "恭喜掌门#{user.name}获得50元宝奖励" if money[:gold] >= 50 

      return if message.nil?

      produce_message(message, '参加活动获得奖励事件触发', method: __method__, file: __FILE__, line: __LINE__)
    end 

    private 
      # 生成消息
      def produce_message(message, info, options = {})
        SysAdMessage.create(message: message, m_type: SysAdMessage::FROM_CLIENT,
                            start_time: Time.now, end_time: Time.now.tomorrow,
                            user_rule: 'all')
        unless options.empty?
          GGA.logger.info("### #{options[:method]}(#{options[:file]},#{options[:line]}) #{info}")
        end 
      end 
  end 
end 
