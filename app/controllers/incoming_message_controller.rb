class IncomingMessageController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    puts params
    render plain: "ok\n"
  end
end