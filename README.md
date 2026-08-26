# Resend Ruby and Rails SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Build](https://github.com/drish/resend-ruby/actions/workflows/build.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/resend.svg)](https://badge.fury.io/rb/resend)

---

## Installation

To install Resend Ruby and Rails SDK, simply execute the following command in a terminal:

Via RubyGems:

```
gem install resend
```

Via Gemfile:

```
gem 'resend'
```

## Setup

First, you need to get an API key, which is available in the [Resend Dashboard](https://resend.com).

```ruby
require "resend"
Resend.api_key = ENV["RESEND_API_KEY"]
```

or

```ruby
require "resend"
Resend.configure do |config|
  config.api_key = ENV["RESEND_API_KEY"]
end
```

The `#api_key` method also accepts a block without arguments, which can be useful for lazy or dynamic loading of API keys.

```ruby
require "resend"
Resend.api_key = -> { ENV["RESEND_API_KEY"] }
```

```ruby
Resend.configure do |config|
  config.api_key = -> { Current.user.resend_api_key } # Assumes the user has a `resend_api_key` attribute.
end
```

## Example

```rb
require "resend"

Resend.api_key = ENV["RESEND_API_KEY"]

params = {
  "from": "onboarding@resend.dev",
  "to": ["delivered@resend.dev", "your@email.com"],
  "html": "<h1>Hello World</h1>",
  "subject": "Hey"
}
r = Resend::Emails.send(params)
puts r
```

You can view all the examples in the [examples folder](https://github.com/drish/resend-ruby/tree/main/examples)

# Rails and ActionMailer support

This gem can be used as an ActionMailer delivery method, add this to your `config/environments/environment.rb` file.

```ruby
config.action_mailer.delivery_method = :resend
```

Create or update your mailer initializer file and replace the placeholder with your Resend API Key.

```rb
# /config/initializers/resend.rb
Resend.api_key = "re_123456"
```

After that you can deliver_now!, example below:

```ruby
#/app/mailers/user_mailer
class UserMailer < ApplicationMailer
  default from: 'you@yourdomain.io'
  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: ["example2@mail.com", "example1@mail.com"], subject: 'Hello from Resend')
  end
end

# anywhere in the app
u = User.new name: "derich"
mailer = UserMailer.with(user: u).welcome_email
mailer.deliver_now!
# => {:id=>"b8f94710-0d84-429c-925a-22d3d8f86916", from: 'you@yourdomain.io', to: ["example2@mail.com", "example1@mail.com"]}
```

# Rails and ActionMailbox support

This gem also provides an Action Mailbox ingress, so you can receive inbound emails through Resend.

Configure Action Mailbox to use the Resend ingress, and make sure your API key is set (it is used to fetch the full message and its attachments):

```ruby
# config/environments/production.rb
config.action_mailbox.ingress = :resend
```

```ruby
# config/initializers/resend.rb
Resend.api_key = "re_123456"
```

Resend delivers inbound emails as `email.received` webhooks. Create a webhook in the [Resend dashboard](https://resend.com/webhooks) (or via `Resend::Webhooks.create`) subscribed to the `email.received` event and pointed at your app:

```
https://example.com/rails/action_mailbox/resend/inbound_emails
```

Then store the webhook's signing secret (`whsec_...`) so the ingress can verify incoming requests. Either add it to your encrypted credentials with `bin/rails credentials:edit`:

```yml
action_mailbox:
  resend_signing_secret: whsec_...
```

or provide it through the `RESEND_INGRESS_SIGNING_SECRET` environment variable.

Each verified webhook is turned back into a full email — using Resend's raw message download when available, and otherwise rebuilding the message from the Received Emails and Attachments APIs — and handed to Action Mailbox for routing like any other ingress:

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  routing /^support@/i => :support
end
```
