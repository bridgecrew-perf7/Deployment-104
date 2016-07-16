class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category

  has_attached_file :cover, styles: { full: "1440x500>", normal2x: "750x590>", normal3x: "1125x885>", thumb2x: "750x450#", thumb3x: "1125x675>", thumb: '400x500>'  },
                    default_url: "/images/:style/missing.png"
  validates_attachment_content_type :cover,
                                    content_type: /\Aimage\/.*\Z/
  has_many :event_attachments, dependent: :destroy

  after_create :set_organizer

  private
    def set_organizer
      self.user ||= User.find_by_email("hello@daydash.co")
    end
end
