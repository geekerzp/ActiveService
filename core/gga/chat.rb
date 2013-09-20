module GGA
  module Chat 
    def init; end 

    # create instance variable for 2 user set channel and queue
    # param1=2, param2=1
    # instance variable is @channel_1_2 = {"channel"=>EM::Channel, "queue"=>EM::Queue}
    def create_channel(param1, param2)
      param1, param2 = arrange_caller_and_calee(param1, param2)
      if instance_variable_get("@channel_#{param1}_#{param2}").nil?
        instance_variable_set("@channel_#{param1}_#{param2}", 
                              { "channel" => EM::Channel, "queue" => EM::Queue })
      end 
    end 

    # get instance variable
    # param1=2, param2=1
    # it will return nil if @channel_1_2 is not present otherwise it return instance variable
    def get_channel(param1, param2, ws)
      param1, param2 = arrange_caller_and_calee(param1, param2)
      if instance_variable_get("@channel_#{param1}_#{param2}").nil?
        return nil 
      end 
      instance_variable_get("@channel_#{param1}_#{param2}")
    end 

    # get instance variable and Subscribing channel
    def subscribe_channel(param1, param2, ws)
      get_channel(param1, param2, ws)["channel"].subscribe {|msg| ws.send msg }
    end 

    # create instance variable
    # subscribe channel
    # return instance variable
    def set_channel(user_one_id, user_two_id, ws)
      if user_one_id != user_two_id
        caller_id, calee_id = arrange_caller_and_calee(user_one_id, user_two_id)
        create_channel(caller_id, calee_id)
        subscribe_channel(caller_id, calee_id)
        get_channel(caller_id, calee_id)
      end 
    end 

    # create individual channel
    def create_user_channel(param1)
      if instance_variable_get("@channel_#{param1}").nil?
        instance_variable_set("@channel_#{param1}", { "channel" => EM::Channel, "queue" => EM::Queue })
      end 
    end 

    # return individual channel
    def get_user_channel(param1,ws)
      if instance_variable_get("@channel_#{param1}").nil?
        puts "Please Ensure Channel Is Present"
        # set_user_channel(param1,ws)
        return nil
      end
      instance_variable_get("@channel_#{param1}")
    end
  end 
end 
