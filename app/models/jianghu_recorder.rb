# vi: set fileencoding=utf-8 :
require 'second_level_cache/second_level_cache'

class JianghuRecorder < ActiveRecord::Base
  acts_as_cached(version: 1, expires_in: 1.week)  # 开启二级缓存

  attr_accessible :fight_time, :is_finish, :item_id, :scene_id, :star, :user_id

  belongs_to :user

  validates :fight_time, :item_id, :scene_id, :star, :user_id, :presence => true
  validates :fight_time, :item_id, :scene_id, :star, :user_id, :numericality => {:greater_than_or_equal_to => 0,
                                                                                  :only_integer => true}

  #
  # 将信息转化为字典形式
  #
  def to_dictionary()
    #解析江湖、条目、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @item_config = ZhangmenrenConfig.instance.item_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    re = {}
    re[:id] = self.id
    re[:scene_id] = self.scene_id
    re[:item_id] = self.item_id
    re[:star] = self.star
    re[:fight_time] = self.fight_time
    re[:is_finish] = self.is_finish ? 1 : 0
    re
  end

  #
  # 获取江湖的详情
  #
  def get_jianghu_details
    #解析江湖、条目、弟子、名称。
    @jh_config = ZhangmenrenConfig.instance.jianghu_config
    @item_config = ZhangmenrenConfig.instance.item_config
    @disciple_config = ZhangmenrenConfig.instance.disciple_config
    @names_config = ZhangmenrenConfig.instance.name_config

    re = {}
    re[:id] = self.id
    re[:scene_id] = self.scene_id
    re[:item_id] = self.item_id
    re[:star] = self.star
    re[:fight_time] = self.fight_time
    re[:is_finish] = self.is_finish ? 1 : 0
    if self.is_finish
      is_finish = '已完成'
    else
      is_finish = '未完成'
    end
    re[:is_finished] = is_finish
    re[:scene_name] = @names_config[@jh_config[self.scene_id]["name"]]
    re[:item_name] = @names_config[@jh_config[self.scene_id]["items"][self.item_id - 1]["name"]]
    re
  end


  #
  # 更新江湖记录
  # @param [Integer] is_finish  是否完成。1：完成，0：没有完成
  # @param [User]    user       用户
  # @param [Integer] scene_id   场景id
  # @param [Integer] item_id    条目id
  # @param [Integer] star       星级评价
  def self.update_recorder(user, scene_id, item_id, star, is_finish)
    recorder = JianghuRecorder.find_by_scene_id_and_item_id_and_user_id(scene_id, item_id, user.id)
    if recorder.nil?
      # 用户第一次闯这个条目
      recorder = JianghuRecorder.new(scene_id: scene_id, item_id: item_id, user_id: user.id,
                                     is_finish: false, star: 0, fight_time: 0)
    end
    if is_finish == 1
      # 闯关成功
      recorder.star = star
      recorder.is_finish = true
    else
      # 闯关失败
      recorder.star = star if recorder.star < star
      recorder.is_finish = false
    end
    recorder.fight_time += 1
    if recorder.save
      return true, recorder.errors.full_messages.join('; ')
    else
      return false, recorder.errors.full_messages.join('; ')
    end

  end

  #
  #
  # 一定要写好注释：主要功能，参数，返回值
  #
  #
  def self.update_recorder_fight_time_and_gold(user, scene_id, item_id, gold)
    recorder = JianghuRecorder.find_by_scene_id_and_item_id_and_user_id(scene_id, item_id, user.id)
    if recorder.nil?
      recorder = JianghuRecorder.new(scene_id: scene_id, item_id: item_id, user_id: user.id,
                                     is_finish: false, star: 0, fight_time: 0)
    end

    recorder.fight_time = 0
    user.gold = gold
    if recorder.save and  user.save
      return true, nil
    else
      return false, recorder.errors.full_messages.join('; ')
    end
  end
end
