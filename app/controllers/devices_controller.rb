class DevicesController < ApplicationController
  protect_from_forgery except: :move

  def index
    @devices_all = Device.all
    @names = Name.all
    @locations = Location.all
    @types = Type.all
    @brands = Brand.all
    @consumables = Consumable.all
    @consumable_types = ConsumableType.all
    @consumable_movements = ConsumableMovement.all

    @q = Device.ransack(params_for_ransack[:q])
    # for disable paginate if any filter set
    if params[:search_field_value].blank?
      @devices = @q.result.page(params[:page])
    else
      @devices = @q.result
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
    locations = Location.all
    respond_to do |format|
      format.json { render json: locations }
    end
  end

  def move
    is_saved = Device.update(params[:device_id], location_id: params[:location_id])
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
