# lib/kafka/rdkafka_consumer.rb
require_relative "../../config/environment" # Load Rails env
require "rdkafka"
require "json"

# Kafka configuration
config = {
  "bootstrap.servers": "localhost:9092",
  "group.id": "user-consumer-group",
  "auto.offset.reset": "earliest"
}

consumer = Rdkafka::Config.new(config).consumer
consumer.subscribe("test-topic")

puts " Rdkafka consumer started. Listening on 'test-topic'..."

begin
  consumer.each do |message|
    payload = message.payload
    puts " Received raw message: #{payload}"

    begin
      data = JSON.parse(payload)

      # Save to PostgreSQL via ActiveRecord
      user = User.create!(
        first_name: data["first_name"],
        last_name:  data["last_name"],
        email:      data["email"],
        phone:      data["phone"]
      )

      puts "Saved to DB: #{user.inspect}"

    rescue JSON::ParserError
      puts "Invalid JSON: #{payload}"

    rescue ActiveRecord::RecordInvalid => e
      puts " Validation error: #{e.message}"
    end
  end

rescue => e
  puts " Error while consuming: #{e.message}"
  sleep 2
  retry
end
