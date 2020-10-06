class IncomingMessageController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    begin
      content = JSON.parse(request.body.string)
    rescue => ex
      puts ex.message
      render plain: "oops\n", status: 400
      return
    end
    filtered_recipients = content['envelope']['recipients'].select do |r|
      /^#{Rails.configuration.my_email_name}/.match(r)
    end
    if filtered_recipients.count < 1
      puts 'no match'
      render plain: 'address didnt match', status: 400
      return
    end

    routing_keys = RoutingKey.where(verified: true, email: filtered_recipients).pluck(:routing_key)
    if routing_keys.count == 0
      puts "invalid or unverified email #{filtered_recipients.join(', ')}"
      render plain: "invalid or unverified email #{filtered_recipients.join(', ')}", status: 400
      return
    end

    content.delete("attachments")

    routing_keys.each do |routing_key|
      body = {
        routing_key: routing_key,
        event_action: "trigger",
        payload: {
          summary: content["headers"]["subject"],
          source: content["headers"]["from"],
          severity: "critical",
          custom_details: content
        }
      }
      r = HTTParty.post(
        'https://events.pagerduty.com/v2/enqueue', 
        body: body.to_json, 
        headers: { 'Content-Type' => 'application/json' }
      )
      puts r
    end
    render plain: "ok\n"
  end
end