class ConsumableMovementsController < ApplicationController
  protect_from_forgery except: :move

  def index
    @consumable_movements = ConsumableMovement.all
  end

  def new
    @consumable_movement = ConsumableMovement.new
  end

  def create
    @consumable_movement = ConsumableMovement.new(consumable_movement_params)
    if @consumable_movement.save
      redirect_to consumable_movements_path
    else
      render :new
    end
  end

  def destroy
    @consumable_movement = ConsumableMovement.find(params[:id])
    @consumable_movement.destroy
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
        devices << [device.name.id, device.name.full_name, location.id]
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
      consumable = '{ "title": "' + @consumable_movement.consumable.title + '", "movement_id": "' + @consumable_movement.id.to_s + '" }'
    else
      consumable = '{ "title": "" }'
    end
    respond_to do |format|
      format.json { render json: consumable }
    end
  end

  def abort
    @consumable_movement = ConsumableMovement.find(params[:movement_id])
    @consumable_movement.destroy
  end

  private

  def consumable_movement_params
    params.require(:consumable_movement).permit(:consumable_id, :location_id)
  end
end
