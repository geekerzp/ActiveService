# In spec/spec_helper.rb add goliath test helper and all dependencies. In my case :

require 'em-synchrony/em-http'
require 'goliath/test_helper'
require 'yajl/json_gem'

Goliath.env = :test

RSpec.configure do |c|
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec\//
  }
end

# in spec/app_spec.rb

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../', 'app')

describe App do
  def config_file
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'app.rb'))
  end

  let(:api_options) { { :config => config_file } }

  it 'renders ' do
    with_api(App, api_options) do
      get_request(:path => '/v1/categories') do |c|
        resp = JSON.parse(c.response)
        categories = resp.map{|r|r['name']}
        categories.to_s.should =~ /Ruby Web Frameworks/
      end
    end
  end
end

# Goliath application dir tree, looks like :

# lsoave@ubuntu:~/rails/github/GGM$ ls -l 
# total 48
# -rw-rw-r-- 1 lsoave lsoave  483 Feb 25 23:06 app.rb
# -rw-rw-r-- 1 lsoave lsoave 6321 Feb 25 23:06 categories.json
# drwxrwxr-x 2 lsoave lsoave 4096 Feb 25 23:06 config
# -rw-rw-r-- 1 lsoave lsoave  381 Feb 25 23:06 Gemfile
# -rw-rw-r-- 1 lsoave lsoave 2293 Feb 25 23:06 Gemfile.lock
# -rw-rw-r-- 1 lsoave lsoave   59 Feb 21 20:37 Procfile
# -rw-rw-r-- 1 lsoave lsoave  123 Feb 25 23:06 Rakefile
# -rw-rw-r-- 1 lsoave lsoave 7003 Feb 21 20:37 README.md
# -rw-rw-r-- 1 lsoave lsoave  238 Feb 25 23:06 README.mongoimport
# drwxrwxr-x 2 lsoave lsoave 4096 Feb 25 23:23 spec
# lsoave@ubuntu:~/rails/github/GGM$ 

# where config and spec subdirs look like :

# lsoave@ubuntu:~/rails/github/GGM$ ls -l config spec
# config:
# total 4
# -rw-rw-r-- 1 lsoave lsoave 870 Feb 25 23:06 app.rb

# spec:
# total 11
# -rw-rw-r-- 1 lsoave lsoave  777 Feb 25 23:06 app_spec.rb
# -rw-rw-r-- 1 lsoave lsoave  218 Feb 25 23:06 spec_helper.rb
# lsoave@ubuntu:~/rails/github/GGM$ 

# the main goliath app is the same as my first post :

require 'em-synchrony/em-mongo'
require 'yajl/json_gem'
require 'goliath'
require 'grape'

class API < Grape::API
  version 'v1', :using => :path
  format :json

  resource 'categories' do
    # http://0.0.0.0:9000/v1/categories/
    get "/" do
      coll = env.mongo.collection('categories') #Connection Pool from Goliath ENV
      coll.find({})
    end
  end
end

class App < Goliath::API
  def response(env)
    API.call(env)
  end
end
