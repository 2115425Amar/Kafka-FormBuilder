# lib/kafka/rdkafka_consumer.rb
require_relative "../../config/environment" # Load Rails env
require "rdkafka"
require "json"

# Kafka configuration
config = {
  "bootstrap.servers": "localhost:9092",
  "group.id": "user-consumer-group",
  "auto.offset.reset": "earliest"
  # Agar group ka offset nahi mile, purane messages se start kare.
}

consumer = Rdkafka::Config.new(config).consumer
consumer.subscribe("test-topic")

puts "Rdkafka consumer started. Listening on 'test-topic'..."

begin
  consumer.each do |message|
    payload = message.payload
    puts "Received raw message: #{payload}"

    begin
      data = JSON.parse(payload)

      user = User.find_or_initialize_by(email: data["email"])
      user.first_name = data["first_name"]
      user.last_name  = data["last_name"]
      user.phone      = data["phone"]
      user.save!

      puts "Saved/Updated to DB: #{user.inspect}"

    rescue JSON::ParserError
      puts "Invalid JSON format: #{payload}"

    rescue ActiveRecord::RecordInvalid => e
      puts "Validation failed: #{e.message}"

    rescue => e
      puts "Unexpected error: #{e.message}"
   
    ensure
      begin
        consumer.commit(offsets: {
          message.topic => {
            message.partition => message.offset + 1
          }
        })
        puts "Committed Kafka message offset: #{message.offset + 1}"
      rescue => commit_error
        puts "Failed to commit offset: #{commit_error.message}"
      end
    end

  end

rescue => e
  puts "Fatal error while consuming: #{e.message}"
  sleep 2
  retry
end
