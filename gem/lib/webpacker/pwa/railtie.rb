require "rails/railtie"

module Webpacker
  module Pwa
    class Railtie < Rails::Railtie
      initializer "webpacker-pwa.proxy" do |app|
        insert_middleware = Webpacker.config.dev_server.present? rescue nil
        if insert_middleware
          app.middleware.insert_before 0,
                                       Rails::VERSION::MAJOR >= 5 ?
                                           Webpacker::Pwa::DevServerProxy : "Webpacker::Pwa::DevServerProxy",
                                       ssl_verify_none: true
        end
      end
    end
  end
end
