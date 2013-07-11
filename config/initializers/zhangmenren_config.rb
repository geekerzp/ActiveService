#encoding: utf-8
require "singleton"
#
# 解析配置文件
#
class ZhangmenrenConfig
  # 单例模式
  include Singleton

  # 弟子，武功，装备和市场的配置信息。都是字典形式。
  attr_accessor :disciple_config, :gongfu_config, :equipment_config, :market_config
  attr_accessor :goods_config, :normal_bag_config, :gift_bag_config, :random_drop_bags_config

  # 所有的残章信息。通过残章id可以得到对应的武功残章信息
  attr_accessor :canzhang_config
  # 所有的残章信息。通过武功id获取该武功的所有残章信息
  attr_accessor :gongfu_canzhang_config
  # 残章抢夺概率配置。
  attr_accessor :canzhang_grab_probability_config

  # 残章的npc生成规则。
  # 残章npc阵容生成规则
  attr_accessor :canzhang_npc_team_config
  # 残章npc弟子装备的生成规则
  attr_accessor :canzhang_npc_disciple_equipments_config
  # 残章npc弟子武功的生成规则
  attr_accessor :canzhang_npc_disciple_gongfus_config

  # vip配置数据
  attr_accessor :vip_config

  # 论剑配置信息
  attr_accessor :lunjian_config

  # 获取姓名名称的配置信息
  attr_accessor :name_config

  # 获取江湖的配置信息, 条目配置信息， 场景配置信息
  attr_accessor :jianghu_config, :item_config, :scene_config

  # 获取不同等级的弟子的经验上线
  attr_accessor :disciple_experiences_config

  # 获取不同等级的用户的经验上线
  attr_accessor :user_experiences_config

  # 获取所有的掌门名称
  attr_accessor :zhangmen_name_config

  # 获取连续登陆奖励皮遏制
  attr_accessor :login_reward_config

  # 获取所有npc配置信息
  attr_accessor :npc_config

  def initialize
    # 解析弟子配置
    disciple_config_path = "#{Rails.root}/config/configurations/disciples.json"
    disciple_config_content = ''
    File.open(disciple_config_path, 'r'){|f| disciple_config_content = f.read }
    disciple_config_array = JSON.parse(disciple_config_content)
    #Rails.logger.debug("弟子配置信息: \n#{JSON.pretty_generate(disciple_config_array).to_s}")
    self.disciple_config = {}
    disciple_config_array["disciples"].each() {|d_info| self.disciple_config[d_info['id'].to_s] = d_info }
    self.disciple_experiences_config = disciple_config_array["disciple_upgrade_experience_array"]
    #Rails.logger.debug("弟子经验配置信息: \n#{JSON.pretty_generate(disciple_experiences_config).to_s}")
    self.user_experiences_config = disciple_config_array["user_upgrade_experience_array"]
    #Rails.logger.debug("用户经验配置信息: \n#{JSON.pretty_generate(user_experiences_config).to_s}")

    # 解析武功
    gongfu_config_path = "#{Rails.root}/config/configurations/gongfus.json"
    gongfu_config_content = ''
    File.open(gongfu_config_path, 'r'){|f| gongfu_config_content = f.read }
    gongfu_config_array = JSON.parse(gongfu_config_content)
    #Rails.logger.debug("武功配置信息: \n#{JSON.pretty_generate(gongfu_config_array).to_s}")
    self.gongfu_config = {}
    gongfu_config_array.each() {|gf_info| self.gongfu_config[gf_info['id'].to_s] = gf_info}

    # 解析装备
    equipment_config_path = "#{Rails.root}/config/configurations/equipments.json"
    equipment_config_content = ''
    File.open(equipment_config_path, 'r'){|f| equipment_config_content = f.read }
    equipment_config_array = JSON.parse(equipment_config_content)
    #Rails.logger.debug("装备配置信息: \n#{JSON.pretty_generate(equipment_config_array).to_s}")
    self.equipment_config = {}
    equipment_config_array.each() {|e_info| self.equipment_config[e_info['id'].to_s] = e_info}

    # 解析市场配置
    market_config_path = "#{Rails.root}/config/configurations/market.json"
    market_config_content = ''
    File.open(market_config_path, 'r'){|f| market_config_content = f.read }
    self.market_config = JSON.parse(market_config_content)
    #Rails.logger.debug("市场配置信息: \n#{JSON.pretty_generate(self.market_config).to_s}")

    self.goods_config = {}
    self.market_config['goods'].each() {|g_info| self.goods_config[g_info['name']] = g_info}
    #Rails.logger.debug("道具配置信息: \n#{JSON.pretty_generate(self.goods_config).to_s}")

    self.normal_bag_config = {}
    self.market_config['normal_bags'].each() {|g_info| self.normal_bag_config[g_info['name']] = g_info}
    #Rails.logger.debug("礼包配置信息: \n#{JSON.pretty_generate(self.gift_bag_config).to_s}")

    self.gift_bag_config = {}
    self.market_config['gift_bags'].each() {|g_info| self.gift_bag_config[g_info['name']] = g_info}
    #Rails.logger.debug("礼包配置信息: \n#{JSON.pretty_generate(self.gift_bag_config).to_s}")

    self.random_drop_bags_config = {}
    self.market_config['random_drop_bags'].each() {|g_info| self.random_drop_bags_config[g_info['bag_id']] = g_info}
    #Rails.logger.debug("掉落组配置信息: \n#{JSON.pretty_generate(self.random_drop_bags_config).to_s}")

    # 解析残章配置
    canzhang_config_path = "#{Rails.root}/config/configurations/canzhang.json"
    canzhang_config_content = ''
    File.open(canzhang_config_path, 'r'){|f| canzhang_config_content = f.read }
    # 将残章信息按照武功id和残章id分别存储，便于查找
    self.canzhang_config = {}
    self.gongfu_canzhang_config = {}
    canzhang_config_origin = JSON.parse(canzhang_config_content)
    canzhang_config_origin['gongfu_canzhangs'].each() do |canzhang_info|
      gongfu_id = canzhang_info['gongfu_id']
      # 获取武功品质
      gongfu = self.gongfu_config[gongfu_id]
      canzhang_info['quality'] = gongfu['quality']

      self.gongfu_canzhang_config[gongfu_id] = canzhang_info
      canzhang_info['canzhangs'].each() do |canzhang|
        self.canzhang_config[canzhang['id']] = canzhang_info
      end
    end
    #Rails.logger.debug("残章配置信息: \n#{JSON.pretty_generate(self.canzhang_config).to_s}")
    #Rails.logger.debug("残章配置信息: \n#{JSON.pretty_generate(self.gongfu_canzhang_config).to_s}")

    # 解析残章抢夺概率
    self.canzhang_grab_probability_config = {}
    canzhang_config_origin['grab_probability'].each() do |info|
      self.canzhang_grab_probability_config[info['quality'].to_i] = info['probability']
    end
    #Rails.logger.debug("残章抢夺概率配置信息: \n#{JSON.pretty_generate(self.canzhang_grab_probability_config).to_s}")

    # 解析残章npc生成规则
    canzhang_npc_config_path = "#{Rails.root}/config/configurations/canzhang_npc.json"
    canzhang_npc_config_content = ''
    File.open(canzhang_npc_config_path, 'r'){|f| canzhang_npc_config_content = f.read }
    canzhang_npc_config = JSON.parse(canzhang_npc_config_content)
    # 解析残章npc阵容的生成规则
    self.canzhang_npc_team_config = {}
    canzhang_npc_config['npc_teams'].each() do |canzhang_npc_team_info|
      self.canzhang_npc_team_config[canzhang_npc_team_info['canzhang_quality'].to_i] = canzhang_npc_team_info
    end
    # 解析残章npc弟子装备生成规则
    self.canzhang_npc_disciple_equipments_config = {}
    canzhang_npc_config['disciple_equipments'].each() do |info|
      self.canzhang_npc_disciple_equipments_config[info['disciple_quality'].to_i] = info
    end
    # 解析残章npc弟子武功生成规则
    self.canzhang_npc_disciple_gongfus_config = {}
    canzhang_npc_config['disciple_gongfus'].each() do |info|
      self.canzhang_npc_disciple_gongfus_config[info['disciple_quality'].to_i] = info
    end
    #Rails.logger.debug("残章npc阵容生成规则配置信息: \n#{JSON.pretty_generate(self.canzhang_npc_team_config).to_s}")
    #Rails.logger.debug("残章npc弟子装备生成规则配置信息: \n" <<
    #                       "#{JSON.pretty_generate(self.canzhang_npc_disciple_equipments_config).to_s}")
    #Rails.logger.debug("残章npc弟子武功生成规则配置信息: \n" <<
    #                       "#{JSON.pretty_generate(self.canzhang_npc_disciple_gongfus_config).to_s}")

    # 解析vip配置
    vip_config_path = "#{Rails.root}/config/configurations/vip.json"
    vip_config_content = ''
    File.open(vip_config_path, 'r'){|f| vip_config_content = f.read }
    vip_config_array = JSON.parse(vip_config_content)['vip']
    #Rails.logger.debug("vip配置信息: \n#{JSON.pretty_generate(vip_config_array).to_s}")
    self.vip_config = {}
    vip_config_array.each() {|info| self.vip_config[info['level'].to_s] = info }

    # 解析论剑配置
    lunjian_config_path = "#{Rails.root}/config/configurations/lunjian.json"
    lunjian_config_content = ''
    File.open(lunjian_config_path, 'r'){|f| lunjian_config_content = f.read }
    self.lunjian_config = JSON.parse(lunjian_config_content)
    #Rails.logger.debug("论剑配置信息: \n#{JSON.pretty_generate(self.lunjian_config).to_s}")

    # 解析名称配置
    name_config_path = "#{Rails.root}/config/configurations/strings.json"
    name_config_content = ''
    File.open(name_config_path, 'r'){|f| name_config_content = f.read }
    self.name_config = JSON.parse(name_config_content)
    #Rails.logger.debug("名称配置信息: \n#{JSON.pretty_generate(self.name_config).to_s}")

    # 解析江湖配置
    jianghu_config_path = "#{Rails.root}/config/configurations/jianghu.json"
    jianghu_config_content = ''
    File.open(jianghu_config_path, 'r'){|f| jianghu_config_content = f.read }
    jianghu_config_array = JSON.parse(jianghu_config_content)
    #Rails.logger.debug("江湖配置信息: \n#{JSON.pretty_generate(jianghu_config_array).to_s}")
    self.jianghu_config = {}
    jianghu_config_array.each() {|d_info| self.jianghu_config[d_info['id'].to_i] = d_info }
    self.item_config = {}
    jianghu_config.keys.each() do |k|
      jianghu_config[k]['items'].each() do |info|
        self.item_config[info['name'].to_s] = info
      end
    end
    #Rails.logger.debug("条目配置信息: \n#{JSON.pretty_generate(item_config).to_s}")


    # 解析掌门名称及位置配置
    zhangmen_name_config_path = "#{Rails.root}/config/configurations/name_config.json"
    zhangmen_name_config_content = ''
    File.open(zhangmen_name_config_path, 'r'){|f| zhangmen_name_config_content = f.read }
    self.zhangmen_name_config = JSON.parse(zhangmen_name_config_content)
    Rails.logger.debug("掌门名称配置信息: \n#{JSON.pretty_generate(self.zhangmen_name_config).to_s}")

    # 解析连续登陆奖励配置
    login_reward_config_path = "#{Rails.root}/config/configurations/continuous_login_rewards.json"
    login_reward_config_content = ''
    File.open(login_reward_config_path, 'r'){|f| login_reward_config_content = f.read }
    self.login_reward_config = JSON.parse(login_reward_config_content)
    Rails.logger.debug("连续登陆配置信息: \n#{JSON.pretty_generate(self.login_reward_config).to_s}")

    # 解析npc配置
    npc_config_path = "#{Rails.root}/config/configurations/npc_config.json"
    npc_config_content = ''
    File.open(npc_config_path, 'r'){|f| npc_config_content = f.read }
    self.npc_config = JSON.parse(npc_config_content)
    Rails.logger.debug("npc配置信息: \n#{JSON.pretty_generate(self.npc_config).to_s}")

  end
end