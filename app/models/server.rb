class Server < ActiveRecord::Base
  attr_accessible :address, :name, :state
end
