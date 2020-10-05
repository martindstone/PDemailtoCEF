require 'httparty'

class RoutingKeysController < ApplicationController
  protect_from_forgery with: :null_session

  def new
    @routing_key = RoutingKey.new
  end

  def create
    if params[:routing_key].nil?
      render plain: "oops\n", status: 400
      return
    end

    begin
      r = RoutingKey.new
      r.routing_key = params[:routing_key]
      r.verified = false
      r.token = SecureRandom.uuid
      r.save
    rescue => ex
      logger.error ex.message
      render plain: "oops!\n", status: 400
      return
    end
    base_url = ENV["BASE_URL"]
    url = "#{base_url}/routing_keys/verify?token=#{r.token}"
    body = {
      event_action: "trigger",
      routing_key: r.routing_key,
      payload: {
        summary: "Verify PDemailtoCEF",
        source: "PDemailtoCEF",
        severity: "critical",
        custom_details: {
          "message": "Someone (possibly you) requested to add this routing key to PDemailtoCEF. To verify this key, please follow this link: #{url}"
        }
      }
    }
    r = HTTParty.post('https://events.pagerduty.com/v2/enqueue', body: body.to_json, headers: { 'Content-Type' => 'application/json' })
    # "/routing_keys/verify?token=#{r.token}\n"
    render plain: r
  end

  def verify
    puts params
    if params[:token].nil?
      render plain: "no token specified\n", status: 400
      return
    end
    token = params[:token]
    r = RoutingKey.find_by(token: token)
    if r.nil?
      render plain: "invalid token\n", status: 400
      return
    end
    r.token = nil
    r.verified = true
    r.save
    render plain: "ok\n"
  end
end
