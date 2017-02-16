module Organizer
  class EventsController < Organizer::BaseController
    before_action :event, only: [:edit, :update, :destroy, :delete_section, :delete_attachment, :dashboard, :orders, :orders_detail, :checkin, :attendees, :published, :unpublish, :order_attachment, :update_attachment]
    before_action :all_categories, only: [:new, :edit]
    before_action :all_users, only: [:new, :edit]
    before_action :admin_only, only: [:unpublish, :published, :update_time_event]

    def index
      if current_user.organizer?
        @events = current_user.events
      else
        @events = Event.all
      end

      @event  = @events.count
      @live   = @events.coming.where(status: :published)
      @draft  = @events.coming.where(status: :unpublish)
      @past   = @events.past

      sort = ['asc', 'desc'].include?(params[:sort_by].try(:downcase)) ? params[:sort_by] : 'desc'

      @events = case params[:filter]
      when 'live'
        @live
      when 'draft'
        @draft
      when 'past'
        @past
      else
        @events
      end.order(uptime: sort)
    end

    def new
      @event = Event.new
      @categories = Category.all
      @organizer = User.organizer
    end

    def create
      if @event = Event.create(event_params)
        serialize_data_create

        redirect_to edit_organizer_event_path(@event.to_url), flash: { notice: "Success!" }
      else
        redirect_to organizer_events_path, flash: { error: @event.errors.full_messages }
      end

      EventUpdateJob.perform_now
    end

    def show
      @event = Event.friendly.find(params[:id])
      @payments = @event.orders
    end

    def edit
      @event = Event.friendly.find(params[:id])
      @categories = Category.all

      @organizer = User.organizer

      @sections = @event.sections
      @images = @event.event_pictures.order(:sort_index)

      @images_order = [];
      @images.each do |image|
        @images_order.push(image.id)
      end

      @category_id = @event.categories.pluck(:id)
    end

    def update
      @event.update(event_params)
      serialize_data_update

      redirect_to edit_organizer_event_path(@event.to_url), flash: { notice: "Success!" }

      EventUpdateJob.perform_now
    end

    def destroy
      @event.destroy
    end

    def order_attachment
      @images = @event.event_pictures.order(:sort_index)

      respond_to do |format|
        # format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
        format.json
      end
    end

    def update_attachment
      @event.event_pictures.where(id: params[:media_id]).update(sort_index: params[:sort_index])
    end

    def delete_attachment
      @event.event_pictures.where(id: params[:media_id]).destroy_all
    end

    def delete_section
      section = @event.sections.find(params[:section_id])
      if section.tickets.present?
        render json: :failure
      else
        section.delete
        render json: :success
      end
    end

    def dashboard
      @orders = @event.orders.where(status: :paid).order(created_at: :desc)
      @total_sales = @orders.sum(&:price) / 100
      @total = @event.sections.total
      @paid = @event.tickets.paid.count
      @percentage = @paid / @total.to_f * 100


      @days_to_go = (@event.uptime.to_date - Time.zone.now.to_date).to_i
      @live = @days_to_go > 0
    end

    def orders
      @orders = @event.orders.includes(:user, :payment).where(status: :paid)

      @orders = case params[:sort_by]
      when 'order_date'
        # binding.pry
        @orders.order(created_at: :asc)
      when 'ticket_buyer'
        @orders.order('users.first_name asc')
      when 'payment'
        # binding.pry
        @orders.order('payments.methods asc')
      # when 'status'
      #   @orders.order(status: :asc)
      else
        @orders.order(created_at: :desc)
      end

      respond_to do |format|
        format.html
        format.xlsx {
          render xlsx: 'orders', filename: "all_orders.xlsx"
          # response.headers['Content-Disposition'] = 'attachment; filename="all_orders.xlsx"'
        }
      end
    end

    def orders_detail
      @order = @event.orders.find_by(code: params[:code])
    end

    def attendees
      # @sections = @event.orders

      respond_to do |format|
        format.html
        format.xlsx {
          render xlsx: 'attendees', filename: "all_attendees.xlsx"
          # response.headers['Content-Disposition'] = 'attachment; filename="all_orders.xlsx"'
        }
      end
    end

    def checkin
      @orders = @event.orders.order(created_at: :desc)
      @sections = @event.sections
    end

    def tickets
    end

    def ticket_checking
      @event = Event.friendly.find(params[:event_id])
      @ticket = @event.tickets.find(params[:ticket_id])

      @ticket.update(status: :used)
      redirect_to :back
    end

    def unpublish
      @event.update(status: :unpublish)
      redirect_to :back
    end

    def published
      @event.update(status: :published)
      EventUpdateJob.perform_now

      redirect_to :back
    end

    def update_time_event
      EventUpdateJob.perform_now
      redirect_to :back
    end

  private

    def serialize_data_create
      user_id = params[:organizer].to_i.eql?(0) ? current_user.id : params[:organizer].to_i
      @event.update(user_id: user_id)

      params[:category_ids].each do |category|
        CategoriesEvent.create(category_id: category, event_id: @event.id) if category.present?
      end unless params[:category_ids].nil?

      params[:event_pictures].each do |attachments|
        EventPicture.create(event: @event, media: attachments)
      end unless params[:event_pictures].nil?

      (0..params[:new_ticket_names].count - 1).each do |section|
        next unless params[:new_ticket_names][section].present? and params[:new_ticket_totals][section].present? and params[:new_ticket_prices][section].present?

        start_date = params[:new_ticket_start_date][section]
        start_time = params[:new_ticket_start_time][section]
        end_date   = params[:new_ticket_end_date][section]
        end_time   = params[:new_ticket_end_time][section]

        if start_date.present? and start_time.present? and end_date.present? and end_time.present?
          event_time = Time.zone.parse("#{start_date} #{start_time}")
          end_time   = Time.zone.parse("#{end_date} #{end_time}")
        end

        new_ticket_discounts = params[:new_ticket_discounts][section].present? ? params[:new_ticket_discounts][section] : 0
        @event.sections.create do |s|
          s.title         = params[:new_ticket_names][section]
          s.total         = params[:new_ticket_totals][section]
          s.price         = params[:new_ticket_prices][section]
          s.discount      = new_ticket_discounts
          s.event_time    = event_time
          s.end_time      = end_time
        end
      end unless params[:new_ticket_names].nil?
    end

    def serialize_data_update
      unless params[:organizer].to_i.eql?(0)
        @event.update(user_id: params[:organizer].to_i)
      end

      # CategoriesEvent.where(event: @event).where.not(category: params[:category_ids]).delete_all
      CategoriesEvent.where(event: @event).delete_all
      params[:category_ids].each do |category|
        CategoriesEvent.create(category_id: category, event_id: @event.id) if category.present?
      end unless params[:category_ids].nil?

      params[:event_pictures].each do |attachments|
        EventPicture.create(event: @event, media: attachments)
      end unless params[:event_pictures].nil?

      @event.sections.each do |section|
        start_date = params["tickets"]["#{section.id}"]["start_date"]
        start_time = params["tickets"]["#{section.id}"]["start_time"]
        end_date   = params["tickets"]["#{section.id}"]["end_date"]
        end_time   = params["tickets"]["#{section.id}"]["end_time"]

        discount = params["tickets"]["#{section.id}"]["discount"].present? ? params["tickets"]["#{section.id}"]["discount"] : 0
        section.update(
          title:      params["tickets"]["#{section.id}"]["title"],
          total:      params["tickets"]["#{section.id}"]["total"],
          price:      params["tickets"]["#{section.id}"]["price"],
          discount:   discount,
          event_time: "#{start_date} #{start_time}",
          end_time:   "#{end_date} #{end_time}"
        )
      end unless params[:tickets].nil?

      (0..params[:new_ticket_names].count - 1).each do |section|
        next unless params[:new_ticket_names][section].present? and params[:new_ticket_totals][section].present? and params[:new_ticket_prices][section].present?

        start_date = params[:new_ticket_start_date][section]
        start_time = params[:new_ticket_start_time][section]
        end_date   = params[:new_ticket_end_date][section]
        end_time   = params[:new_ticket_end_time][section]

        if start_date.present? and start_time.present? and end_date.present? and end_time.present?
          event_time = Time.zone.parse("#{start_date} #{start_time}")
          end_time   = Time.zone.parse("#{end_date} #{end_time}")
        end

        new_ticket_discounts = params[:new_ticket_discounts][section].present? ? params[:new_ticket_discounts][section] : 0
        @event.sections.create do |s|
          s.title         = params[:new_ticket_names][section]
          s.total         = params[:new_ticket_totals][section]
          s.price         = params[:new_ticket_prices][section]
          s.discount      = new_ticket_discounts
          s.event_time    = event_time
          s.end_time      = end_time
        end
      end unless params[:new_ticket_names].nil?
    end

    def event
      @event = Event.friendly.find(params[:id])
    end

    def event_params
      params.permit(:title, :slug, :ticket_type, :uptime, :short_description, :whythis, :cover, :social_share, :show_highlight, :description, :instruction, :location_name, :location_address, :latitude, :longitude, :share_ticket)
    end

    def all_categories
      @categories = Category.all
    end

    def all_users
      # @users = Role.find_by_title('organizer').users
    end
  end
end
