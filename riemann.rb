require 'chef/handler'
require 'riemann/client'

module DataSift
  class RiemannHandler < ::Chef::Handler
    attr_writer :host, :port, :ttl, :timeout

    def initialize(options={})
      @host = options[:host]
      @port = options[:port]
      @ttl = options[:ttl]
      @timeout = options[:timeout] || 5
    end

    def report
      # create TCP riemann client
      riemann = Riemann::Client.new(host: @host, port: @port, timeout: @timeout).tcp

      unless end_time
        # chef run has started
        riemann << {
          :service => 'process:chef-client:state',
          :state => 'running',
          :description => "Chef run has started at #{start_time}"
        }
      else
        # chef run has completed

        # send summary, covers overall state and elapsed time
        if run_status.success?
          riemann << {
            service: 'process:chef-client:state',
            state: 'ok',
            description: "Chef succeeded at #{end_time}",
            metric: elapsed_time,
            ttl: @ttl
          }

          riemann << {
            service: "process:chef-client:updated_resources",
            metric:  run_status.updated_resources.length,
            ttl: @ttl
          }

          riemann << {
            service: "process:chef:all_resources",
            metric: run_status.all_resources.length,
            ttl: @ttl
          }
        else
          riemann << {
            service: 'process:chef-client:state',
            state: 'critical',
            description: "Chef failed at #{end_time}: " + run_status.formatted_exception,
            metric: elapsed_time,
            ttl: @ttl
          }
        end
      end
    end
  end
end
