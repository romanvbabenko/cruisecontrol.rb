module CruiseControl

  class Log

    def self.verbose=(verbose)
      @verbose = verbose
    end

    def self.verbose?
      @verbose or false
    end

    def self.event(description, severity = :info)
      return if severity == :debug and not @verbose
      message = "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{description}"
      Log.send(severity.to_sym, message)
    end

    def self.method_missing(method, *args, &block)
      return if method == :debug && !@verbose
      first_arg = args.shift
      message = backtrace = nil

      case first_arg
      when Exception
        message = "#{print_severity(method)} #{first_arg.message}"
        backtrace = first_arg.backtrace.map { |line| "#{print_severity(method)}   #{line}" }
      else
        message = "#{print_severity(method)} #{first_arg}"
      end

      logger.send(method, message, *args, &block)
      backtrace.each { |line| logger.send(method, line) } if backtrace
      is_error = (method == :error || method == :fatal)

      if ( @verbose || is_error ) && ( defined?(Rails) && !Rails.env.test? )
        stream = is_error ? STDERR : STDOUT
        stream.puts message
        backtrace.each { |line| stream.puts line } if backtrace and @verbose
      end
    end

    # nicely aligned printout of message severity
    def self.print_severity(severity)
      severity = severity.to_s
      '[' + severity + ']' + ' ' * (5 - severity.length)
    end

    private

    def self.logger
      # defined?(::RAILS_DEFAULT_LOGGER) ? ::RAILS_DEFAULT_LOGGER : Logger.new($stderr)
      defined?(Rails) ? Rails.logger : Logger.new($stderr)
    end
  end
end