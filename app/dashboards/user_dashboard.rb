require "admin/base_dashboard"

class UserDashboard < Admin::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Admin::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    referrer: Field::BelongsTo.with_options(class_name: "User"),
    events: Field::HasMany,
    orders: Field::HasMany,
    tickets: Field::HasMany,
    wishlists: Field::HasMany,
    referrals: Field::HasMany.with_options(class_name: "User"),
    id: Field::Number,
    username: Field::String,
    email: Field::String,
    encrypted_password: Field::String,
    first_name: Field::String,
    last_name: Field::String,
    gender: Field::String,
    birthday: Field::DateTime,
    phone: Field::String,
    picture_file_name: Field::String,
    picture_content_type: Field::String,
    picture_file_size: Field::Number,
    picture_updated_at: Field::DateTime,
    role: Field::String,
    provider: Field::String,
    uid: Field::String,
    access_token: Field::String,
    omise_customer_id: Field::String,
    onesignal_id: Field::String,
    company: Field::String,
    url: Field::String,
    interest: Field::String,
    short_description: Field::Text,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    unconfirmed_email: Field::String,
    failed_attempts: Field::Number,
    unlock_token: Field::String,
    locked_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    referal_code: Field::String,
    referrer_id: Field::Number,
    slug: Field::String,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :referrer,
    :events,
    :orders,
    :tickets,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :referrer,
    :events,
    :orders,
    :tickets,
    :wishlists,
    :referrals,
    :id,
    :username,
    :email,
    :encrypted_password,
    :first_name,
    :last_name,
    :gender,
    :birthday,
    :phone,
    :picture_file_name,
    :picture_content_type,
    :picture_file_size,
    :picture_updated_at,
    :role,
    :provider,
    :uid,
    :access_token,
    :omise_customer_id,
    :onesignal_id,
    :company,
    :url,
    :interest,
    :short_description,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :confirmation_token,
    :confirmed_at,
    :confirmation_sent_at,
    :unconfirmed_email,
    :failed_attempts,
    :unlock_token,
    :locked_at,
    :created_at,
    :updated_at,
    :referal_code,
    :referrer_id,
    :slug,
    :latitude,
    :longitude,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :referrer,
    :events,
    :orders,
    :tickets,
    :wishlists,
    :referrals,
    :username,
    :email,
    :encrypted_password,
    :first_name,
    :last_name,
    :gender,
    :birthday,
    :phone,
    :picture_file_name,
    :picture_content_type,
    :picture_file_size,
    :picture_updated_at,
    :role,
    :provider,
    :uid,
    :access_token,
    :omise_customer_id,
    :onesignal_id,
    :company,
    :url,
    :interest,
    :short_description,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :confirmation_token,
    :confirmed_at,
    :confirmation_sent_at,
    :unconfirmed_email,
    :failed_attempts,
    :unlock_token,
    :locked_at,
    :referal_code,
    :referrer_id,
    :slug,
    :latitude,
    :longitude,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
