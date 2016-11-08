module Admin
  class EventsController < Admin::BaseController
    before_action :event, only: [:edit, :update, :destroy, :delete_attachment, :orders, :checkin, :published, :unpublish]
    before_action :all_categories, only: [:new, :edit]
    before_action :all_users, only: [:new, :edit]
    before_action :admin_only, only: [:unpublish, :published, :update_time_event]

    def index
      if current_user.organizer?
        @events = current_user.events.order(created_at: :desc)
      else
        @events = Event.order(created_at: :desc)
      end
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
    end

    def destroy
      @event.destroy
    end

    def delete_attachment
      @event.event_pictures.where(id: params[:media_id]).destroy_all
      redirect_to :back
    end

    def orders
      @orders = @event.orders.where(status: :paid).order(created_at: :desc)
    end

    def tickets
    end

    def checkin
      @orders = @event.orders.order(created_at: :desc)
      @sections = @event.sections
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
        next unless params[:new_ticket_names][section].present? and params[:new_ticket_totals][section].present? and params[:new_ticket_prices][section].present? and params[:new_ticket_initials][section].present?

        if params[:new_ticket_event_time][section].present? and params[:new_ticket_end_time][section].present?
          event_time = Time.zone.parse(params[:new_ticket_event_time][section])
          end_time   = Time.zone.parse(params[:new_ticket_end_time][section])
        end

        @event.sections.create do |s|
          s.title       = params[:new_ticket_names][section]
          s.total       = params[:new_ticket_totals][section]
          s.price       = params[:new_ticket_prices][section]
          # s.unit        = params[:new_ticket_units][section]
          s.initial_price = params[:new_ticket_initials][section]
          s.event_time  = event_time
          s.end_time    = end_time
        end
      end unless params[:new_ticket_names].nil?
    end

    def serialize_data_update
      unless params[:organizer].to_i.eql?(0)
        @event.update(user_id: params[:organizer].to_i)
      end

      CategoriesEvent.where(event: @event).where.not(category: params[:category_ids]).delete_all
      params[:category_ids].each do |category|
        CategoriesEvent.create(category_id: category, event_id: @event.id) if category.present?
      end unless params[:category_ids].nil?

      params[:event_pictures].each do |attachments|
        EventPicture.create(event: @event, media: attachments)
      end unless params[:event_pictures].nil?

      # update section
      @event.sections.each do |section|
        section.update(
          title:      params["tickets"]["#{section.id}"]["title"],
          total:      params["tickets"]["#{section.id}"]["total"],
          price:      params["tickets"]["#{section.id}"]["price"],
          # unit:       params["tickets"]["#{section.id}"]["unit"],
          initial_price:       params["tickets"]["#{section.id}"]["initial_price"],
          event_time: params["tickets"]["#{section.id}"]["event_time"],
          end_time:   params["tickets"]["#{section.id}"]["end_time"]
        )
      end unless params[:tickets].nil?

      (0..params[:new_ticket_names].count - 1).each do |section|
        next unless params[:new_ticket_names][section].present? and params[:new_ticket_totals][section].present? and params[:new_ticket_prices][section].present? and params[:new_ticket_initials][section].present?

        if params[:new_ticket_event_time][section].present? and params[:new_ticket_end_time][section].present?
          event_time = Time.zone.parse(params[:new_ticket_event_time][section])
          end_time   = Time.zone.parse(params[:new_ticket_end_time][section])
        end

        @event.sections.create do |s|
          s.title       = params[:new_ticket_names][section]
          s.total       = params[:new_ticket_totals][section]
          s.price       = params[:new_ticket_prices][section]
          # s.unit        = params[:new_ticket_units][section]
          s.initial_price = params[:new_ticket_initials][section]
          s.event_time  = event_time
          s.end_time    = end_time
        end
      end unless params[:new_ticket_names].nil?
    end

    def event
      @event = Event.friendly.find(params[:id])
    end

    def event_params
      params.permit(:title, :slug, :ticket_type, :short_description, :whythis, :cover, :social_share, :show_highlight, :description, :instruction, :location_name, :location_address, :latitude, :longitude, :share_ticket)
    end

    def all_categories
      @categories = Category.all
    end

    def all_users
      # @users = Role.find_by_title('organizer').users
    end
  end
end