# vi: set fileencoding=utf-8 :
#
# 对象序列化模块
#
module RecordMarshal
  class << self
    # dump ActiveRecord instace with only attributes.
    # ["User",
    #  {"id"=>30,
    #  "email"=>"dddssddd@gmail.com",
    #  "created_at"=>2012-07-25 18:25:57 UTC
    #  }
    # ]

    # 序列化一个对象
    def dump(record)
      [
       record.class.name,
       record.attributes
      ]
    end

    # load a cached record
    # 反序列化一个对象
    def load(serialized)
      return unless serialized
      # constantize可以通过字符串获取字符串所代表的类
      # allocate可以生成一个没有初始化的对象
      record = serialized[0].constantize.allocate
      record.init_with('attributes' => serialized[1])
      record
    end

    # 反序列化多个对象
    def load_multi(serializeds)
      serializeds.map{|serialized| load(serialized)}
    end
  end
end
