class ConsumableMovementsController < ApplicationController
  protect_from_forgery except: [:move, :abort]

  def index
    @consumable_movements = ConsumableMovement.order(id: :desc).page(params[:page])
  end

  def new
    @consumable_movement = ConsumableMovement.new
  end

  def create
    @consumable_movement = ConsumableMovement.new(consumable_movement_params)
    @consumable_movement.consumable.increment!(:quantity_ready_to_refill)
    @consumable_movement.consumable.decrement!(:quantity_in_stock)
    if @consumable_movement.save
      record_activity new_obj: @consumable_movement
      redirect_to consumable_movements_path
    else
      render :new
    end
  end

  def destroy
    @consumable_movement = ConsumableMovement.find(params[:id])
    @consumable_movement.destroy
    record_activity old_obj: @consumable_movement
    redirect_to consumable_movements_path
  end

  def change_cartridge
    @disable_nav = true
  end

  def get_locations
    locations = Location.all
    respond_to do |format|
      format.json { render json: locations }
    end
  end

  def get_devices
    devices = []
    location = Location.find_by(department: params[:department], room: params[:room])
    devices_in_room = Device.where(location_id: location.id)
    devices_in_room.each do |device|
      if device.name.type.id == params[:type_id].to_i
        if device.name.image.attached?
          img_path = rails_representation_url(device.name.image.variant(resize: '200x200'),
                                              only_path: true)
        end
        devices << [device.name.id,
                    device.name.full_name,
                    location.id,
                    img_path]
      end
    end
    devices = devices.uniq { |device| device[0] }
    respond_to do |format|
      format.json { render json: devices }
    end
  end

  def move
    consumable = nil
    consumables = Name.find(params[:name_id]).consumable
    consumables.each do |consum|
      if consum.consumable_type.id == params[:consumable_type_id].to_i
        consumable = consum
      end
    end
    @consumable_movement = ConsumableMovement.new
    if !consumable.nil?
      @consumable_movement.attributes = { consumable_id: consumable.id, location_id: params[:location_id] }
    end
    if @consumable_movement.save
      consumable = '{ "title": "' + @consumable_movement.consumable.title +
                   '", "movement_id": "' + @consumable_movement.id.to_s +
                   '", "placement": "' + @consumable_movement.consumable.placement + '" }'
      if @consumable_movement.consumable.quantity_in_stock > 0
        @consumable_movement.consumable.increment!(:quantity_ready_to_refill)
        @consumable_movement.consumable.decrement!(:quantity_in_stock)
      else
        consumable = '{ "title": null }'
      end
      record_activity new_obj: @consumable_movement,
                      action: 'create',
                      info: record_activity_info
    else
      consumable = '{ "title": "" }'
    end
    respond_to do |format|
      format.json { render json: consumable }
    end
  end

  def abort
    @consumable_movement = ConsumableMovement.find(params[:movement_id])
    @consumable_movement.consumable.decrement!(:quantity_ready_to_refill)
    @consumable_movement.consumable.increment!(:quantity_in_stock)
    @consumable_movement.destroy
    record_activity old_obj: @consumable_movement,
                    action: 'destroy',
                    info: record_activity_info
  end

  private

  def consumable_movement_params
    params.require(:consumable_movement).permit(:consumable_id, :location_id)
  end

  def record_activity_info
    info = @consumable_movement.consumable.consumable_type.title + ' ' +
           @consumable_movement.consumable.title + ' moved to ' +
           @consumable_movement.location.history_title
  end

end
