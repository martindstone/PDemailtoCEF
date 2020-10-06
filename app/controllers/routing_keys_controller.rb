include Generator
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
      @routing_key = RoutingKey.new
      @routing_key.routing_key = params[:routing_key]
      @routing_key.verified = false
      @routing_key.token = SecureRandom.uuid
      if @routing_key.valid?
        @routing_key.save
      else
        render :new
      end
    rescue => ex
      logger.error ex.message
      redirect_to new_routing_key_path, flash: { error: ex.message }
      return
    end
    base_url = ENV["BASE_URL"]
    url = "#{base_url}/routing_keys/verify?token=#{@routing_key.token}"
    body = {
      event_action: "trigger",
      routing_key: @routing_key.routing_key,
      payload: {
        summary: "Verify PDemailtoCEF",
        source: "PDemailtoCEF",
        severity: "critical",
        custom_details: {
          "message": "Someone (possibly you) requested to add this routing key to PDemailtoCEF. To verify this key, please follow this link: #{url}"
        }
      }
    }
    res = HTTParty.post('https://events.pagerduty.com/v2/enqueue', body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def verify
    if params[:token].nil?
      redirect_to new_routing_key_path, flash: { error: 'no token was specified'}
      return
    end
    token = params[:token]
    r = RoutingKey.find_by(token: token)
    if r.nil?
      redirect_to new_routing_key_path, flash: { error: 'invalid or expired token'}
      return
    end
    email = "#{Rails.configuration.my_email_name}+#{NameGenerator.generate_name}@#{Rails.configuration.my_email_domain}"
    r.email = email
    r.token = nil
    r.verified = true
    r.save
    @routing_key = r
  end

  def delete
  end

  def destroy
    if params[:routing_key].nil?
      render plain: "oops\n", status: 400
      return
    end
    r = RoutingKey.find_by(routing_key: params[:routing_key])
    if r.nil?
      redirect_to delete_routing_keys_path, flash: { error: "Routing key #{params[:routing_key]} wasn't found"}
      return
    end
    if not r.verified
      redirect_to delete_routing_keys_path, flash: { error: "Routing key #{params[:routing_key]} isn't verified yet"}
      return
    end
    r.token = SecureRandom.uuid
    r.save
    base_url = ENV["BASE_URL"]
    url = "#{base_url}/routing_keys/unverify?token=#{r.token}"
    body = {
      event_action: "trigger",
      routing_key: r.routing_key,
      payload: {
        summary: "Unverify PDemailtoCEF",
        source: "PDemailtoCEF",
        severity: "critical",
        custom_details: {
          "message": "Someone (possibly you) requested to remove this routing key from PDemailtoCEF. To unverify this key, please follow this link: #{url}"
        }
      }
    }
    res = HTTParty.post('https://events.pagerduty.com/v2/enqueue', body: body.to_json, headers: { 'Content-Type' => 'application/json' })
    @routing_key = r
  end

  def unverify
    if params[:token].nil?
      redirect_to delete_routing_keys_path, flash: { error: "no token was specified"}
      return
    end
    token = params[:token]
    r = RoutingKey.find_by(token: token)
    if r.nil?
      redirect_to delete_routing_keys_path, flash: { error: "invalid or expired token"}
      return
    end
    r.destroy
    @routing_key = r
  end
end
