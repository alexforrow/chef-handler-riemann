require 'chef/handler'
require 'riemann/client'

class Chef
  class Handler
    class Riemann < ::Chef::Handler
      attr_writer :host, :port, :ttl_running, :ttl_finished, :timeout

      def initialize(options={})
        # Some versions of Chef had issues as chef-client cookbook passes it with string indicies
        options = Mash.from_hash(options)

        @host = options[:host] || 'localhost'
        @port = options[:port] || 5555
        @ttl_running = options[:ttl_running] || 600
        @ttl_finished = options[:ttl_finished] || 3600 # seems reasonable given chef runs every 30 mins by default
        @timeout = options[:timeout] || 5
      end

      def report
        begin
          # create TCP riemann client
          riemann = ::Riemann::Client.new(host: @host, port: @port, timeout: @timeout).tcp

          unless end_time
            # chef run has started
            riemann << {
              :service => 'process:chef-client:state',
              :state => 'running',
              :description => "Chef run has started at #{start_time}",
              :ttl => @ttl_running
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
                ttl: @ttl_finished
              }

              riemann << {
                service: "process:chef-client:updated_resources",
                metric:  run_status.updated_resources.length,
                ttl: @ttl_finished
              }

              riemann << {
                service: "process:chef-client:all_resources",
                metric: run_status.all_resources.length,
                ttl: @ttl_finished
              }
            else
              riemann << {
                service: 'process:chef-client:state',
                state: 'critical',
                description: "Chef failed at #{end_time}: " + run_status.formatted_exception,
                metric: elapsed_time,
                ttl: @ttl_finished
              }
            end
          end
        rescue Exception => e
          Chef::Log.error "Failed to send report to Riemann: #{e.message}"
        end
      end
    end
  end
end
