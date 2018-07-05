require "json"
require "net/http"
require "uri"

module OpsGenie
  class Alert
    extend Helper

    class << self
      def create params
        http_post("/v2/alerts", params) if should_alert?
      end
    end
  end
end
