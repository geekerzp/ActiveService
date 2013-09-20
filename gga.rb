require 'harmonious_dictionary/gga'
require 'singleton'
HarmoniousDictionary::Gga.instance.root = File.expand_path(File.dirname(__FILE__))
module GGA
  class Root
    include Singleton

    attr_accessor :root
    def initialize
      @root = File.expand_path(File.dirname(__FILE__))
    end

  end
end