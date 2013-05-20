class PayRecorder < ActiveRecord::Base
  attr_accessible :p_type, :user_id

  belongs_to :user
end
