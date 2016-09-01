# == Schema Information
#
# Table name: orders
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  event_id             :integer
#  invoice_no           :string
#  status               :string
#  code                 :string
#  qr_code_file_name    :string
#  qr_code_content_type :string
#  qr_code_file_size    :integer
#  qr_code_updated_at   :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_orders_on_event_id  (event_id)
#  index_orders_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_64bd9e45d4  (event_id => events.id)
#  fk_rails_f868b47f6a  (user_id => users.id)
#

class Order < ApplicationRecord
  ORDER_NO_PADDING = 10000

  belongs_to :user, inverse_of: :orders
  belongs_to :event, inverse_of: :orders

  has_one :payment, dependent: :destroy

  has_many :tickets, dependent: :destroy

  has_attached_file :qr_code, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :qr_code, content_type: /\Aimage\/.*\z/

  before_create :set_default_order_code
  after_create :set_default_order_qr_code
  after_create :set_invoice_no

  scope :available, -> { all.reject{ |p| p.tickets.empty? } }
  enumerize :status, in: [:approved, :pending, :cancel], default: :pending

  def approve!
    self.update(status: :approved)
  end

  def order_by_event_upcoming
    # available.order_by()
  end

  def to_s
    "#OD-#{code}"
  end

  def to_no
    self.id + ORDER_NO_PADDING
  end

private
  def generate_code
    loop do
      code = App.generate_code
      break code unless Order.exists?(code: code)
    end
  end

  def set_default_order_code
    self.code = generate_code
  end

  def set_default_order_qr_code
    attachment = App.generate_qr_code(self)
    self.update(qr_code: File.open(attachment, 'rb'))
  end

  def set_invoice_no
    self.update(invoice_no: "#{to_s}-#{to_no}-#{Time.zone.now.to_i}")
  end
end