module DogEventer
  class EventEmitter
    attr_reader :events

    def wait(seconds)
      @start_time += seconds
    end
  end

  class NagiosCheck < EventEmitter
    attr_reader :host

    def initialize(check_name, host, start_time)
      @check_name = check_name
      @host = host
      @start_time = start_time
      @events = []
    end

    def msg_title(alert_state)
      "#{@check_name} is #{alert_state.to_s} on #{@host}"
    end

    def event_object()
      @check_name
    end

    def event_type()
      "monitoring.alert"
    end

    def alert_type(state)
      {
        :critical => :error,
        :ok       => :success,
        :warning  => :warning,
        :warn     => :warn
      }[state]
    end

    def date_happened(date=nil)
      (date || @start_time).to_i
    end

    def source_type_name()
      "Nagios"
    end

    def to_event(alert_state, date=nil)
      @events << {
        :event_object  => event_object,
        :event_type    => event_type,
        :alert_type    => alert_type(alert_state),
        :date_happened => date_happened(date),
        :msg_title     => msg_title(alert_state),
        :source_type_name => source_type_name,
        :host          => host
      }
    end

    def critical(date=nil)
      to_event :critical
    end

    def warning(date=nil)
      to_event :warning
    end

    def ok(date=nil)
      to_event :ok
    end
  end

  class PingdomCheck < EventEmitter
    attr_reader :url

    def initialize(check_name, url, start_time)
      @check_name = check_name
      @url = url
      @start_time = start_time
      @events = []
    end

    def msg_title(alert_state)
      "#{@check_name} is #{alert_state.to_s}"
    end

    def event_object()
      @check_name
    end

    def event_type()
      "monitoring.alert"
    end

    def alert_type(state)
      {
        :down => :error,
        :up   => :success
      }[state]
    end

    def date_happened(date=nil)
      (date || @start_time).to_i
    end

    def source_type_name()
      "Pingdom"
    end

    def to_event(alert_state, date=nil)
      @events << {
        :event_object  => event_object,
        :event_type    => event_type,
        :alert_type    => alert_type(alert_state),
        :date_happened => date_happened(date),
        :msg_title     => msg_title(alert_state),
        :source_type_name => source_type_name,
        :host          => "Pingdom:#{@check_name}"
      }
    end

    def down(date=nil)
      to_event :down
    end
    def up(date=nil)
      to_event :up
    end

  end
end
