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
    @departments = Location::DEPARTMENTS

    @q = Device.order(:id).ransack(params_for_ransack(params.dup))
    @devices_result = set_department(cookies[:department])
    cookies[:per_page] = Device.per_page if cookies[:per_page].blank?
    @devices = @devices_result.paginate(page: params[:page],
                                        per_page: cookies[:per_page])

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

  def params_for_ransack(ransack_params)
    # search by several words
    unless ransack_params.dig(:q, :name_cont).blank? && ransack_params.dig(:q, :location_cont).blank?
      @will_paginate = false
      ransack_params[:q][:combinator] = 'and'
      ransack_params[:q][:groupings] = []
      ransack_params = split_query_words(:name_cont, ransack_params)
      ransack_params = split_query_words(:location_cont, ransack_params)
    end
    ransack_params[:q]
  end

  def split_query_words(search_field, ransack_params)
    query_str = ransack_params[:q].delete(search_field.to_s)
    query_str.split(' ').each do |word|
      ransack_params[:q][:groupings] << { search_field => word }
    end
    ransack_params
  end

  def set_department(department)
    unless department.blank?
      result = []
      @q.result.each do |device|
        result << device if device.location.department == department
      end
      @q.result.where(id: result.map(&:id))
    else
      @q.result
    end
  end
end
