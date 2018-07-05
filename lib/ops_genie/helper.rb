module OpsGenie
  module Helper

    def should_alert?
      OpsGenie.configuration.send_alerts
    end

    def http_post endpoint, params
      uri = URI(File.join(OpsGenie.configuration.base_url, endpoint))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      JSON.parse(http.post(uri.path, ops_params(params)).body)
    end

    private

    def ops_params params
      params.merge!(api_key: OpsGenie.configuration.api_key)
      HashConverter.to_camel_case(params).to_json
    end
  end
end
