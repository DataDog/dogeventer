module Eventer
  class Scope
    attr_reader :events
    def initialize(start_time, events=nil)
      @start_time = start_time
      @events = events || []
    end
  end

  class Host < Scope
    def initialize(start_time, host_name)
      super start_time
      @host_name = host_name
    end
  
    def nagios_check(check_name, &block)
      n = NagiosCheck.new(check_name, @host_name, @start_time)
      n.instance_eval &block
      @events += n.events
    end
  end

  class Url < Scope
    def initialize(start_time, url)
      super start_time
      @url = url
    end
  
    def pingdom_check(check_name, &block)
      p = PingdomCheck.new(check_name, @url, @start_time)
      p.instance_eval &block
      @events += p.events
    end
  end
end

