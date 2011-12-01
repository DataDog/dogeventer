require 'dogapi'
require 'eventer/scope'
require 'eventer/event_emitter'

module Eventer
  class Eventer
    def initialize(api_key, application_key=nil)
      @dog = Dogapi::Client.new(api_key, application_key)
      @events = []
    end

    def generate(start_time, &block)
      @start_time = start_time
      instance_eval &block
    
      @events.each do |event|
        puts event.inspect
        @dog.emit_event(Dogapi::Event.new('', event), :host => event[:host])
      end
    end

    def host(host_name, &block)
      h = Host.new(@start_time, host_name)
      @events += (h.instance_eval &block)
    end
  
    def url(url, &block)
      u = Url.new(@start_time, url)
      @events += (u.instance_eval &block)
    end
  
  end
end

def eventer(start_time=nil, api_key=nil, application_key=nil, &block)
  require 'optparse'
  
  api_key = nil
  app_key = nil
  start_time = nil

  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: eventer [--app_key=APP_KEY] --api_key=API_KEY --time=TIME"
    opts.on("-t", "--time TIME", Float, "start time") { |v| start_time = v }
    opts.on("--api_key API_KEY", "api key") { |v| api_key = v }
    opts.on("--app_key [APP_KEY]", "app key") { |v| app_key = v }
  end
  optparse.parse!
  
  Eventer::Eventer.new(api_key, application_key).generate start_time, &block
end

