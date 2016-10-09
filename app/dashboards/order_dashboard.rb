require "administrate/base_dashboard"

class OrderDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    event: Field::BelongsTo,
    payment: Field::HasOne,
    tickets: Field::HasMany,
    id: Field::Number,
    invoice_no: Field::String,
    status: Field::String,
    code: Field::String,
    qr_code_file_name: Field::String,
    qr_code_content_type: Field::String,
    qr_code_file_size: Field::Number,
    qr_code_updated_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    price: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :event,
    :payment,
    :tickets,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :event,
    :payment,
    :tickets,
    :id,
    :invoice_no,
    :status,
    :code,
    :qr_code_file_name,
    :qr_code_content_type,
    :qr_code_file_size,
    :qr_code_updated_at,
    :created_at,
    :updated_at,
    :price,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :event,
    :payment,
    :tickets,
    :invoice_no,
    :status,
    :code,
    :qr_code_file_name,
    :qr_code_content_type,
    :qr_code_file_size,
    :qr_code_updated_at,
    :price,
  ].freeze

  # Overwrite this method to customize how orders are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(order)
  #   "Order ##{order.id}"
  # end
end
