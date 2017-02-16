# == Schema Information
#
# Table name: events
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  title                     :string
#  description               :text
#  instruction               :text
#  location_name             :string
#  location_address          :string
#  latitude                  :decimal(10, 6)
#  longitude                 :decimal(10, 6)
#  uptime                    :datetime
#  max_price                 :integer
#  min_price                 :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  slug                      :string
#  name                      :string
#  ticket_type               :string
#  status                    :string
#  show_highlight            :boolean          default(FALSE)
#  total_of_ticket           :integer          default(0)
#  share_ticket              :boolean          default(FALSE)
#  cover_file_name           :string
#  cover_content_type        :string
#  cover_file_size           :integer
#  cover_updated_at          :datetime
#  short_description         :text
#  social_share_file_name    :string
#  social_share_content_type :string
#  social_share_file_size    :integer
#  social_share_updated_at   :datetime
#  whythis                   :text
#
# Indexes
#
#  index_events_on_slug     (slug) UNIQUE
#  index_events_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_0cb5590091  (user_id => users.id)
#

class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  belongs_to :user
  belongs_to :category

  has_and_belongs_to_many :categories

  has_many :wishlists,      dependent: :destroy
  has_many :event_pictures, dependent: :destroy
  has_many :orders,         dependent: :destroy
  has_many :tickets,        dependent: :destroy
  has_many :sections,       dependent: :destroy
  accepts_nested_attributes_for :sections, reject_if: :all_blank, allow_destroy: true

  has_attached_file :cover, styles: { full: "1600x500#" }
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\z/

  has_attached_file :social_share, styles: { facebook: "1200x630#" }, default_url: '/facebook-og.png'
  validates_attachment_content_type :social_share, content_type: /\Aimage\/.*\z/
  # after_create :set_organizer
  # after_create :set_uptime
  # def set_uptime
  #   uptime = sections.available.min_by(&:event_time).event_time
  # end

  enumerize :ticket_type, in: [:general, :deal], default: :general
  enumerize :status, in: [:published, :unpublish], default: :unpublish

  scope :available, -> { joins(:sections).where('sections.event_time > ?', Time.zone.now).uniq }
  scope :today,     -> { joins(:sections).where('sections.event_time': Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :tomorrow,  -> { joins(:sections).where('sections.event_time': Time.zone.tomorrow.beginning_of_day..Time.zone.tomorrow.end_of_day) }
  scope :upcoming,  -> { joins(:sections).where('DATE(sections.event_time) > ?', Time.zone.tomorrow) }

  scope :past, -> { where('uptime < ?', Time.zone.now) }
  scope :coming, -> { where('uptime > ?', Time.zone.now) }

  scope :list,      -> { where(status: :published).where('uptime > ?', Time.zone.now).order(:uptime) }

  after_create :set_slug

  def to_url
    slug || id
  end

  def to_uptime
    if self.ticket_type.general?
      uptime.try(:strftime, "%A %d %B, %H:%M")
    else
      'สามารถเข้าร่วมได้ทุกวัน'
    end
  end

  def order_by_section
    sections.available.order(:event_time)
  end

  def first_section
    self.sections.available.min_by{|s| [s.event_time, s.price] }
  end

  def get_thumbnail
    self.event_pictures.order(:sort_index).try(:first).try(:media, :thumb) || ''
  end

  def get_cover
    self.try(:cover, :full) || self.event_pictures.order(:sort_index).try(:first).try(:media, :full)
  end

  def get_total_sales
    orders.paid.sum(:price).to_f / 100
  end

  def self.update_uptime_present
    # all.each do |event|
    #   if event.ticket_type.general?
    #     event_time = event.sections.available.min_by(&:event_time).try(:event_time)
    #     event.update(uptime: event_time) unless event_time.nil?
    #   else
    #     event.update(uptime: Time.zone.now + [*7..10].sample.days)
    #   end
    # end
  end

  def self.update_deal_event
    where(ticket_type: :deal).each do |event|
      event.update(uptime: Time.zone.now + [*7..10].sample.days)
    end
  end

  def organizer_status
    return if self.uptime.nil?

    if self.uptime < Time.zone.now
      "past"
    elsif self.status == 'published'
      'live'
    else
      'draft'
    end
  end

private
  def set_slug
    if self.slug.blank?
      set_slug_var = self.title.parameterize.downcase

      if set_slug_var.blank?
        self.slug = self.title
      elsif Event.exists?(slug: set_slug_var)
        i = 0
        loop do
          break self.slug = "#{set_slug_var}-#{i}" unless Event.exists?(slug: "#{set_slug_var}-#{i}")
          i += 1
        end
      else
        self.slug = set_slug_var
      end
    end
  end

  def set_organizer
    self.user ||= User.find_by_email('hello@daydash.co')
  end
end
