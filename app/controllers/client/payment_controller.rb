module Client
  class PaymentController < Client::BaseController
    before_action :event_payment, only: [:selection, :express, :checkout]
    before_action :related_events, only: [:show, :checkout]

    def index
      @covers = [
        { image: '/src/images/content/cover-1.jpg', caption: '<h1 class="title">ประสบการณ์ใหม่ๆ มีอยู่รอบตัว</h1><div class="subtitle">Daydash ค้นพบกิจกรรมสนุกๆ อีเว้นท์เจ๋งๆ ที่พร้อมให้คุณออกไปสัมผัสได้ทุกวัน</div>' },
      ]

      if params[:category].present?
        @category_id = Category.friendly.find(params[:category]).id
      else
        @category_id = nil
      end
      @events = Event.list
    end

    def show
      @event    = Event.where('lower(slug) = ?', params[:id].downcase).first
      @section_count = @event.sections.count

      @sections = @event.ticket_type.deal? ? @event.sections.order(:event_time): @event.sections.available

      @section  = @event.sections.min_by { |m| m.price }

      set_seo_title @event.try(:title)
      set_meta_tags description: @event.try(:short_description),
      og: {
        title:          @event.try(:title),
        image: {
            _:          @event.try(:social_share, :facebook) || @event.event_pictures.try(:first).try(:media, :facebook),
            url:        @event.try(:social_share, :facebook) || @event.event_pictures.try(:first).try(:media, :facebook),
            width:      1200,
            height:     630,
          },
        latitude:       @event.try(:latitude),
        longitude:      @event.try(:longitude),
        email:          @event.try(:email),
        phone:          @event.try(:phone),
        street_address: @event.try(:location_address),
        location:       @event.try(:location_name),
        start_time:     @event.try(:uptime),
        end_time:       @event.try(:uptime),
      },
      twitter: {
        title:            @event.try(:title),
        image: {
          _:              @event.try(:social_share, :facebook) || @event.event_pictures.try(:first).try(:media, :facebook),
          url:            @event.try(:social_share, :facebook) || @event.event_pictures.try(:first).try(:media, :facebook),
          width:          1200,
          height:         630,
        },
        card:             'summary_large_image'
      }
    end

    def selection
      set_seo_title @event.try(:title)

      total = 0
      session[:event]    = @event.id
      session[:tickets]  = {}
      session[:sections] = []

      sections = []
      @event.sections.each do |section|
        sections << params[:section]["#{section.id}"].to_i
        if params[:section]["#{section.id}"].to_i > 0
          raise "you need to hack more limit tickets" if params[:section]["#{section.id}"].to_i > section.show_ticket_available
          total += section.price * params[:section]["#{section.id}"].to_i
          session[:tickets].merge!({
            "#{section.id}": {
              title: section.title,
              price: section.price,
              quantity: params[:section]["#{section.id}"].to_i,
            }
          })
          session[:sections] << { "id": section.id, "price": section.price.to_i * 100, "qty": params[:section]["#{section.id}"].to_i }
        end
      end

      raise unless sections.any?{ |x| x > 0 }

      session[:tickets][:total] = total.to_i * 100

      redirect_to client_event_express_path(@event.to_url)
    rescue Exception => e
      session[:event]    = nil
      session[:tickets]  = nil
      session[:sections] = nil
      redirect_back
    end

    def express
      set_seo_title @event.try(:title)

      redirect_to root_url unless @event.id == session[:event]
      @tickets = session[:tickets]
      @is_free = true if @tickets["total"].to_i == 0
    end

    def checkout
      set_seo_title 'Checkout'

      dob = Date.strptime("#{params[:dob_date]}/#{params[:dob_month]}/#{params[:dob_year]}", "%d/%m/%Y")

      current_user.update(
        first_name: params[:firstname],
        last_name:  params[:lastname],
        phone:      params[:phone],
        birthday:   dob,
        gender:     params[:gender],
      )

      @order = Order.create(user: current_user, event: @event, price: session["tickets"]["total"])
      case params[:payment_method]
      when 'credit_card'
        @payment = Payment.omise_token_charge(@order, params[:omise_token])

        if @payment[:status] == :error
          raise @payment[:message]
        else
          @order.approve!
        end
      when 'bank_transfer'
        @payment = Payment.transfer_notify(@order)
      when 'free'
        raise "error" if @event.sections.min_by(&:price).price > 0
        @payment = Payment.free(@order)
        @order.approve!
      end

      sections = []
      session[:sections].each{|s| sections << Hashie::Mash.new(s)}

      if @payment[:status] != :error
        sections.each do |section|
          (1..section.qty).each do |i|
            Ticket.create_ticket(current_user, @order, @event, section)
          end
          Section.cut_in(section.id, section.qty, @event)
        end
      else
        raise @payment[:message]
      end

      @order.send_notify!
      render :checkout
    rescue Exception => e
      flash[:credit_card_error] = 'ข้อมูลบัตรไม่ถูกต้องค่ะ กรุณาตรวจสอบอีกครั้งค่ะ'
      redirect_back
    end

  private
    def related_events
      @related_events = Event.where.not(slug: params[:id]).list.first(3)
    end

    def event_payment
      @event = Event.friendly.find(params[:event_id].downcase)
    end
  end
end