module OpsGenie
  module Helper

    def should_alert?
      OpsGenie.configuration.send_alerts
    end

    def http_post(endpoint, params)
      uri = URI(File.join(OpsGenie.configuration.base_url, endpoint))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      response = http.post(uri.path, ops_params(params), headers)
      JSON.parse(response.body)
    end

    private

    def ops_params(params)
      HashConverter.to_camel_case(params).to_json
    end

    def headers
      {
        "Authorization" => "GenieKey #{ OpsGenie.configuration.api_key }",
        "Content-Type" => "application/json"
      }
    end
  end
end
