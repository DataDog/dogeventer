require 'dogapi'
require 'dogeventer/scope'
require 'dogeventer/event_emitter'

module DogEventer
  class DogEventer
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

def dogeventer(start_time=nil, api_key=nil, application_key=nil, &block)
  require 'optparse'
  
  all_config = {
    :default => {:start_time => Time.now.to_i - 60*60},
    :cli => {},
    :file => {}
  }
  config_file = "~/.dogrc"
  
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{$0} [options]"
    opts.on("-t", "--time TIME", Float, "Start time in seconds since unix epoch. Defaults to the current time minus an hour.") { |v| 
      all_config[:cli][:start_time] = start_time
    }
    opts.on("-c", "--config CONFIG_FILE", "Path to config file. Defaults to #{config_file}") { |v|
      config_file = v
    }
    opts.on("--api_key API_KEY", "Api key. Overrides config values.") { |v| 
      all_config[:cli][:api_key] = v
    }
    opts.on("--app_key [APP_KEY]", "App key. Overrides config values.") { |v| 
      all_config[:cli][:app_key] = v
    }
    
  end
  optparse.parse!

  if not config_file
    config_file = default_config_file
  end
  
  config_file = File.expand_path config_file
  if File.exists? config_file
    File.open(config_file) do |f| 
      f.readlines.each do |line|
        keyval = line.split "="
        if keyval.length == 2
          key = keyval[0].strip
          val = keyval[1].strip
          if key == 'apikey'
            all_config[:file][:api_key] = val
          elsif key == 'appkey'
            all_config[:file][:app_key] = val
          end
        end
      end
    end
  end
  
  config = all_config.reduce({}) do |merged, to_merge|
    merged.merge to_merge[1]
  end
  
  DogEventer::DogEventer.new(config[:api_key], config[:app_key]).generate config[:start_time], &block
end

