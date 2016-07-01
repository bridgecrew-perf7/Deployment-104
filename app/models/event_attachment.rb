class EventAttachment < ActiveRecord::Base

  belongs_to :event

  has_attached_file :media, styles: { medium: "300x300>", thumb: "100x100#" }
                    # ,
                    # default_url: "/images/:style/missing.png"
  # validates_attachment_content_type :media
  # # ,
  # #                                   content_type: /\Aimage\/.*\Z/
end
