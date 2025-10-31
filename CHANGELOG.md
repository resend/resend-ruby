# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-31

### Overview

This major release introduces breaking changes to the Contacts API and deprecates the Audiences API in favor of Segments. **If you only use the SDK for sending emails or the Audiences API, you can upgrade to v1.0.0 without any code changes.** The breaking changes are limited to the Contacts API only.

### ⚠️ BREAKING CHANGES

#### Contacts API Changes

- ⚠️ **Change `Contacts.create` to accept hash parameter with optional `audience_id`** - Previously required `audience_id` in params, now it's optional. Supports global contacts.
- ⚠️ **Change `Contacts.get` from `get(audience_id, id)` to `get(params)`** - Now accepts a hash with optional `audience_id` and required `id` or `email`. Raises `ArgumentError: "Missing \`id\` or \`email\` field"` when neither is provided.
- ⚠️ **Change `Contacts.list` from `list(audience_id, params = {})` to `list(params = {})`** - Now accepts a hash with optional `audience_id` and pagination params
- ⚠️ **Change `Contacts.remove` from `remove(audience_id, contact_id)` to `remove(params)`** - Now accepts a hash with optional `audience_id` and required `id` or `email`. Raises `ArgumentError: "Missing \`id\` or \`email\` field"` when neither is provided.
- ⚠️ **Change `Contacts.update` error message** - Error changed from `"id or email is required"` to `"Missing \`id\` or \`email\` field"` to match Node.js SDK format
- ⚠️ **Change `Contacts.update` to accept optional `audience_id`** - Previously required `audience_id` in params, now it's optional

**Before (v0.x):**

```ruby
# Methods used positional arguments and required audience_id
Resend::Contacts.create(audience_id: "aud_123", email: "user@example.com", first_name: "John")
contact = Resend::Contacts.get("aud_123", "contact_123")
contacts = Resend::Contacts.list("aud_123")
contacts = Resend::Contacts.list("aud_123", limit: 10)
Resend::Contacts.update(audience_id: "aud_123", id: "contact_123", first_name: "Jane")
Resend::Contacts.remove("aud_123", "contact_123")
```

**After (v1.0.0):**

```ruby
# Methods use hash parameters and support optional audience_id
# Global contacts (no audience_id)
Resend::Contacts.create(email: "user@example.com", first_name: "John")
contact = Resend::Contacts.get(id: "contact_123")
contact = Resend::Contacts.get(email: "user@example.com")
contacts = Resend::Contacts.list
contacts = Resend::Contacts.list(limit: 10)
Resend::Contacts.update(id: "contact_123", first_name: "Jane")
Resend::Contacts.remove(id: "contact_123")

# Audience-scoped contacts (with audience_id)
Resend::Contacts.create(audience_id: "aud_123", email: "user@example.com", first_name: "John")
contact = Resend::Contacts.get(audience_id: "aud_123", id: "contact_123")
contacts = Resend::Contacts.list(audience_id: "aud_123", limit: 10)
Resend::Contacts.update(audience_id: "aud_123", id: "contact_123", first_name: "Jane")
Resend::Contacts.remove(audience_id: "aud_123", id: "contact_123")
```

#### Audiences API Deprecated

- ⚠️ **Deprecate `Resend::Audiences` in favor of `Resend::Segments`** - The Audiences module has been replaced with Segments. A backward-compatible alias `Audiences = Segments` has been added, so existing code will continue to work.

**Migration (Recommended):**

Update your code to use `Segments` instead of `Audiences`:

```ruby
# Before (still works but deprecated)
Resend::Audiences.create(name: "My Audience")
Resend::Audiences.get("audience_123")
Resend::Audiences.list
Resend::Audiences.remove("audience_123")

# After (recommended)
Resend::Segments.create(name: "My Segment")
Resend::Segments.get("segment_123")
Resend::Segments.list
Resend::Segments.remove("segment_123")
```

**Note:** The `Audiences` alias is deprecated and may be removed in a future major version. Please migrate to `Segments`.

### Added

#### New API Modules

- Add `Resend::Templates` API for managing email templates
  - `Templates.create` - Create a new template
  - `Templates.get` - Retrieve a template by ID
  - `Templates.update` - Update an existing template
  - `Templates.publish` - Publish a template
  - `Templates.duplicate` - Duplicate an existing template
  - `Templates.list` - List all templates with pagination
  - `Templates.remove` - Delete a template
- Add `Resend::Topics` API for managing topics
  - `Topics.create` - Create a new topic
  - `Topics.get` - Retrieve a topic by ID
  - `Topics.update` - Update a topic
  - `Topics.list` - List all topics with pagination
  - `Topics.remove` - Delete a topic
- Add `Resend::Segments` API for managing segments (replacement for Audiences)
  - `Segments.create` - Create a new segment
  - `Segments.get` - Retrieve a segment by ID
  - `Segments.list` - List all segments
  - `Segments.remove` - Delete a segment
- Add `Resend::ContactProperties` API for managing custom contact properties
  - `ContactProperties.update` - Update contact properties (validates and raises `ArgumentError: "Missing \`id\` field"` when id is not provided)
  - `ContactProperties.get` - Retrieve contact properties by ID
- Add `Resend::Contacts::Segments` API for managing contact-segment relationships
  - `Contacts::Segments.list` - List all segments for a contact
  - `Contacts::Segments.add` - Add a contact to a segment
  - `Contacts::Segments.remove` - Remove a contact from a segment
- Add `Resend::Contacts::Topics` API for managing contact topic subscriptions
  - `Contacts::Topics.list` - List topic subscriptions for a contact
  - `Contacts::Topics.update` - Update topic subscriptions (opt-in/opt-out) for a contact

#### Contacts API Enhancements

- Add support for `email` parameter in `Contacts.get` and `Contacts.remove` methods (can now use email instead of ID)
- Add `audience_id` support in Contacts API methods for scoped operations
- Add support for global contacts (contacts not scoped to a specific audience/segment)
- Add validation error messages matching Node.js SDK format with backticks around field names

#### Broadcasts API Updates

- Add deprecation warnings for `audience_id` in `Broadcasts.create` and `Broadcasts.update` (use `segment_id` instead)

### Removed

- Remove deprecated `send_email` method from `Resend::Emails` module (use `Resend::Emails.send` instead)

[1.0.0]: https://github.com/resend/resend-ruby/compare/v0.26.0...v1.0.0
