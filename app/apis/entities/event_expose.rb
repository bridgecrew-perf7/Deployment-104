class Entities::EventExpose < Grape::Entity
  include ActionView::Helpers::TextHelper

  expose :id
  expose :title
  expose :description do |item, option|
    "<body>#{simple_format(item.description)}</body>"
  end
  expose :location_name
  expose :location_address
  expose :latitude
  expose :longitude
  expose :min_price do |item, option|
    if item.sections.available.min_by{|s| s.price }.price == 0
      'free'
    else
      item.sections.available.min_by{|s| s.price }.price
    end
  end
  expose :uptime, as: :up_time do |item, option|
    item.uptime.utc.iso8601
  end
  expose :ticket_type
  expose :order_by_section, as: :tickets, using: Entities::SectionExpose
  expose :categories, using: Entities::CategoryExpose
  expose :event_pictures, as: :covers, using: Entities::GalleryExpose
end
