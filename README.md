Here’s a clean and detailed `README.md` documentation for your Kafka + Rails setup:

---

## 📦 User Data Kafka Integration in Ruby on Rails

This Rails application demonstrates how to integrate **Kafka (via `rdkafka`)** to **send and consume user data** asynchronously. It supports:

- Sending form data to a Kafka topic (`test-topic`)
- Consuming data from Kafka
- Saving new user data into PostgreSQL
- Updating existing users if the email already exists

---

### 🛠️ Tech Stack

- **Ruby on Rails** – Web framework
- **Kafka** – Message broker
- **rdkafka** – Kafka client for Ruby (bindings to [librdkafka](https://github.com/edenhill/librdkafka))
- **PostgreSQL** – Database
- **Tailwind CSS** – UI styling

---

## 🚀 Features

- Submit user data from a styled form (`first name`, `last name`, `email`, `phone`)
- Produce JSON messages to Kafka (`test-topic`)
- Kafka consumer:
  - Listens for new messages
  - Parses data
  - Updates existing users or creates new ones based on `email`
  - Commits Kafka offsets after processing
- Input validations (e.g. email format, Indian phone numbers)

---

## 📂 Project Structure

```bash
├── app
│   ├── controllers
│   │   └── users_controller.rb         # Handles form submission and Kafka producer
│   ├── models
│   │   └── user.rb                     # User model with validations
│   └── views
│       └── users
│           └── new.html.erb            # Tailwind CSS-styled form
├── lib
│   └── kafka
│       └── rdkafka_consumer.rb         # Kafka consumer that saves/updates DB
├── config
│   └── routes.rb                       # Defines `/users/new` and `/users` routes
```

---

## 🧪 Validations

- All fields are required
- Email must be valid and unique
- Phone must be a valid Indian 10-digit mobile number (`6xxxxxxxxx` - `9xxxxxxxxx`)

---

## 🔄 Kafka Setup & Usage

### ✅ Prerequisites

- Kafka running on `localhost:9092`
- Ruby `rdkafka` gem installed (and `librdkafka` installed via system packages)

### ⚙️ Producing Data

From the Rails form:

1. Go to `/users/new`
2. Fill out the form
3. Submit → Sends data to Kafka topic `test-topic`

### 📥 Consuming Data

Run the consumer script:

```bash
ruby lib/kafka/rdkafka_consumer.rb
```

- Listens to topic `test-topic`
- Parses JSON
- Saves or updates user record in PostgreSQL
- Commits offset after each message

---

## 🧹 Optional Kafka Cleanup

To delete messages from a topic after processing, you can:
- Enable log compaction for the topic (for upserts)
- Or manually reset the offsets:

```bash
bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --group user-consumer-group \
  --topic test-topic \
  --reset-offsets --to-latest --execute
```

⚠️ This doesn't delete messages from Kafka (Kafka retains them per log retention config), it only resets **what the consumer reads**.

---

## 💡 Tips

- Use `User.find_or_initialize_by(email: ...)` to prevent duplicates
- Wrap Kafka consumer in a background service (e.g. Sidekiq/Resque/Process manager)
- Tailwind UI can be further enhanced using component libraries like [Tailwind UI](https://tailwindui.com/)

---

## 📬 Sample Kafka Message Format

```json
{
  "first_name": "Aman",
  "last_name": "Sharma",
  "email": "aman@example.com",
  "phone": "9876543210"
}
```

---


