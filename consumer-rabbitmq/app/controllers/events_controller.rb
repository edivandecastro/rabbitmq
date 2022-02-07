class EventsController < ApplicationController
  before_action :set_event, only: %i[ edit update destroy ]

  # GET /events or /events.json
  def index
    @events = Event.all
  end

  # GET /events/1 or /events/1.json
  def show
    conn = Bunny.new("amqp://rabbitmq:rabbitmq@localhost:5672")
    # Está conexão fica aberta
    conn.start

    channel = conn.create_channel
    queue = channel.queue("orders", durable: true)

    # Retirada manual da fila: :manual_ack => true
    queue.subscribe(:manual_ack => true) do |delivery_info, metadata, payload|
      if Event.create(
        name: "Received #{payload}",
        description: "Tag #{delivery_info.delivery_tag}",
        start_time: DateTime.now,
        end_time: DateTime.now,
        active: true
      )
        # if o event foi persistido no bando remove a mensagem da fila do rabbitmq
        channel.ack(delivery_info.delivery_tag, false)
      end
    end

    @event = Event.last
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to event_url(@event), notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to event_url(@event), notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:name, :description, :start_time, :end_time, :active)
    end
end
