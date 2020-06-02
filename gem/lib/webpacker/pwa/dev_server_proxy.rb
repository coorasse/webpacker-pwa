require "rack/proxy"
require "webpacker"

module Webpacker
  module Pwa
    class DevServerProxy < Rack::Proxy
      def initialize(app = nil, opts = {})
        @webpacker = opts.delete(:webpacker) || Webpacker.instance
        opts[:streaming] = false if Rails.env.test? && !opts.key?(:streaming)
        super
      end

      def perform_request(env)
        service_workers_entry_path = dev_server.config.send(:fetch, :service_workers_entry_path)
        return unless service_workers_entry_path.present?
        service_workers_folder = dev_server.config.source_path.join(service_workers_entry_path)
        service_workers = Dir[service_workers_folder.join('*')].map { |e| "/#{File.basename(e)}" }
        if (service_workers.include?(env["PATH_INFO"])) && dev_server.running?
          env["HTTP_HOST"] = env["HTTP_X_FORWARDED_HOST"] = dev_server.host
          env["HTTP_X_FORWARDED_SERVER"] = dev_server.host_with_port
          env["HTTP_PORT"] = env["HTTP_X_FORWARDED_PORT"] = dev_server.port.to_s
          env["HTTP_X_FORWARDED_PROTO"] = env["HTTP_X_FORWARDED_SCHEME"] = dev_server.protocol
          unless dev_server.https?
            env["HTTPS"] = env["HTTP_X_FORWARDED_SSL"] = "off"
          end
          env["SCRIPT_NAME"] = ""

          super(env)
        else
          @app.call(env)
        end
      end

      private

      def config
        @webpacker.config
      end

      def dev_server
        @webpacker.dev_server
      end
    end
  end
end
