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
    puts content
    my_addr = ENV["CLOUDMAILIN_FORWARD_ADDRESS"]
    my_addr_name = my_addr.split('@')[0]
    filtered_recipients = content['envelope']['recipients'].select do |r|
      /^#{my_addr_name}/.match(r)
    end
    if filtered_recipients.count < 1
      puts 'no match'
      render plain: 'address didnt match', status: 400
      return
    end
    addr_parts = filtered_recipients.first.split(/[@\+]/)
    if addr_parts.count != 3
      puts 'wrong split'
      render plain: 'invalid address', status: 400
      return
    end
    routing_key = addr_parts[1]

    if RoutingKey.where(verified: true).find_by(routing_key: routing_key).nil?
      puts "invalid or unverified routing key #{routing_key}"
      render plain: "invalid or unverified routing key #{routing_key}", status: 400
      return
    end

    content.delete("attachments")
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
    r = HTTParty.post('https://events.pagerduty.com/v2/enqueue', body: body.to_json, headers: { 'Content-Type' => 'application/json' })
    puts r
    render plain: "ok\n"
  end
end