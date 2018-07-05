require 'spec_helper'

describe OpsGenie do
  describe '#configure' do
    before do
      OpsGenie.configure do |config|
        config.api_key = 'key'
        config.base_url = 'https://api.opsgenie.com/'
        config.send_alerts = true
      end
    end

    describe OpsGenie::Alert do
      let(:requests) {[
        '{"message":"hello","apiKey":"key"}',
        '{"message":"hello","description":"a common greeting","apiKey":"key"}',
        '{"message":"hello","randomField":"hello","details":{"someDetails":"hello"},"apiKey":"key"}',
        '{"message":"hello","responders":[{"name":"API","type":"team"},{"name":"Support","type":"team"}],"apiKey":"key"}',
      ]}

      before do
        requests.each do |body|
          stub_request(:post, 'https://api.opsgenie.com/v2/alerts')
            .with(body: body)
            .to_return(status: 200, body: '{"status":"successful"}', headers: {})
        end
      end

      context 'the alert_release_stages is not configured' do
        it 'sends a request to the api with a message and an api_key' do
          OpsGenie::Alert.create(message: 'hello')

          expect(OpsGenie).to have_sent_alert { |payload|
            expect(payload['apiKey']).to eq('key')
            expect(payload['message']).to eq('hello')
          }
        end

        it 'sends a request to the api with a description' do
          OpsGenie::Alert.create(message: 'hello', description: 'a common greeting')

          expect(OpsGenie).to have_sent_alert { |payload|
            expect(payload['description']).to eq('a common greeting')
          }
        end

        it 'sends a request to the api with camelized keys' do
          OpsGenie::Alert.create(message: 'hello', random_field: 'hello', details: { some_details: 'hello' })
          expect(OpsGenie).to have_sent_alert { |payload|
            expect(payload['randomField']).to eq('hello')
          }
        end

        it 'sends a list of teams to be alerted' do
          OpsGenie::Alert.create(message: 'hello', responders: [{ name: 'API', type: 'team' }, { name: 'Support', type: 'team' }])
          expect(OpsGenie).to have_sent_alert { |payload|
            expect(payload['responders'].map { |r| r['name'] }).to eq(['API', 'Support'])
          }
        end
      end

      context 'the release_stage is not in the alert_release_stages' do
        before do
          OpsGenie.configuration.send_alerts = false
        end

        it 'does not send alerts' do
          expect(OpsGenie::Alert.create(message: 'hello')).not_to \
            have_requested(:post, 'https://api.opsgenie.com/v2/alerts')
        end
      end
    end
  end
end
