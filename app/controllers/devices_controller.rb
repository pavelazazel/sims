class DevicesController < ApplicationController
  protect_from_forgery except: [:move, :is_swappable]

  def index
    @devices_all = Device.all
    @names = Name.all
    @locations = Location.all
    @types = Type.all
    @brands = Brand.all
    @consumables = Consumable.all
    @consumable_types = ConsumableType.all
    @consumable_movements = ConsumableMovement.all

    @q = Device.order(:id).ransack(params_for_ransack[:q])
    # for disable paginate if any filter set
    @devices = if params[:search_field_value].blank?
                 @q.result.page(params[:page])
               else
                 @q.result
               end

    # Excel export
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=stock.xlsx"
      }
      format.html { render :index }
    end
  end

  def show
    @device = Device.find(params[:id])
  end

  def new
    @device = Device.new
  end

  def edit
    @device = Device.find(params[:id])
  end

  def create
    @device = Device.new(device_params)
    if @device.save
      redirect_to devices_path
    else
      render :new
    end
  end

  def update
    @device = Device.find(params[:id])
    if @device.update(device_params)
      redirect_to @device
    else
      render :edit
    end
  end

  def destroy
    @device = Device.find(params[:id])
    @device.destroy
    redirect_to devices_path
  end

  def get_departments
    departments = Location::DEPARTMENTS
    respond_to do |format|
      format.json { render json: departments }
    end
  end

  def get_locations
    locations = Location.all.sort { |x, y| x.room.to_i <=> y.room.to_i }
    respond_to do |format|
      format.json { render json: locations }
    end
  end

  def is_swappable
    type_id = Device.find(params[:device_id]).name.type.id
    devices_in_room = Device.where(location_id: params[:location_id])
    count = 0
    devices_in_room.each do |d|
      count += 1 if d.name.type.id == type_id
    end
    respond_to do |format|
      format.json { render json: '{ "swap": "' + (count == 1).to_s + '" }' }
    end
  end

  def move
    if ActiveModel::Type::Boolean.new.cast(params[:swap])
      swap_device_id = nil
      target_device = Device.find(params[:device_id])
      devices_in_room = Device.where(location_id: params[:location_id])
      devices_in_room.each do |d|
        if d.name.type.id == target_device.name.type.id
          swap_device_id = d.id
          break
        end
      end
      is_saved = Device.update(swap_device_id, location_id: target_device.location.id) &&
                 Device.update(target_device.id, location_id: params[:location_id])
    else
      is_saved = Device.update(params[:device_id], location_id: params[:location_id])
    end
    respond_to do |format|
      format.json { render json: '{ "title": "' + is_saved.to_s + '" }' }
    end
  end

  private

  def device_params
    params.require(:device).permit(:name_id, :inventory_number,
                                   :serial_number, :location_id, :comment)
  end

  def params_for_ransack
    # search by several words
    unless params.dig(:q, :device_attrs_in_any).nil?
      params[:search_field_value] = params[:q][:device_attrs_in_any]
      params[:q][:combinator] = 'or'
      params[:q][:groupings] = []
      query_str = params[:q].delete('device_attrs_in_any')
      query_str.split(' ').each_with_index do |word, index|
        params[:q][:groupings][index] = { device_attrs_in: word }
      end
    end
    params
  end
end
