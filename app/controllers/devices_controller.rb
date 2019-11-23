class DevicesController < ApplicationController
	def index
    @devices = Device.all
    @names = Name.all
    @locations = Location.all
    @types = Type.all
    @brands = Brand.all

    if !params[:q].nil?
      if !params[:q][:all_devices_in_any].nil?
        params[:q][:all_devices_in_any] = params[:q][:all_devices_in_any].split(' ')
      end
    end
    @q = Device.ransack(params[:q])
    @devices = @q.result

    # Excel export
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=devices.xlsx"
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

  private

  def device_params
    params.require(:device).permit(:name_id, :inventory_number, :serial_number, :location_id, :comment)
  end
end
