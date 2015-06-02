# chef-handler-riemann
Chef Handler that reports to Riemann.

It reports when the Chef run starts and finishes, and outputs associated events depending on outcome.

# Usage

TODO: Need to integrate into `chef_handler` cookbook for installation

Editing client.rb works though:

```
require '/var/chef/handlers/riemann.rb'

riemann = DataSift::RiemannHandler.new host: '192.168.122.1', port: 5555, timeout: 5, ttl: 120

start_handlers << riemann
report_handlers << riemann
exception_handlers << rieman
```
