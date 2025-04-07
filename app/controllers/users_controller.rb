# app/controllers/users_controller.rb
require "rdkafka"
require "json"

class UsersController < ApplicationController
  def new
  end

  def create
    user_data = {
      first_name: params[:first_name],
      last_name:  params[:last_name],
      email:      params[:email],
      phone:      params[:phone]
    }

    message = user_data.to_json

    begin
      config = {
        "bootstrap.servers": "localhost:9092"
      }

      producer = Rdkafka::Config.new(config).producer

      # Produce and deliver messageamar8
      delivery_handle = producer.produce(
        topic:   "test-topic",
        payload: message
      )

      delivery_handle.wait # wait for delivery confirmation

      flash[:notice] = "User data sent to Kafka!"

    rescue => e
      Rails.logger.error "Kafka Error: #{e.message}"
      flash[:alert] = " Failed to send to Kafka."
    end

    redirect_to "/users/new"
  end
end
