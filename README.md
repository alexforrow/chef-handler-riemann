# chef-handler-riemann

Chef Handler that reports to Riemann.

It reports when the Chef run starts and finishes, and outputs associated events depending on outcome.

# Usage

This is available as a [gem](https://rubygems.org/gems/chef-handler-riemann)

Because this handler has support for start events, you can't use the `chef_handler` cookbook. Instead, it needs to be added to `client.rb`. The community [chef-client](https://github.com/opscode-cookbooks/chef-client) cookbook can help with this, as it provides easy methods for making `client.rb` load the gem and add the handler. Example usage:

```
# Riemann handler
node.default['chef_client']['load_gems']['chef-handler-riemann'] = {}

[ 'start', 'report', 'exception' ].each do |type|
  node.default['chef_client']['config']["#{type}_handlers"] = [
    {
      :class => "Chef::Handler::Riemann",
      :arguments => [ { :host => "localhost" } ]
    }
  ]
end
```
