class LocationsController < ApplicationController
  def index
    @locations = Location.order(:id)
  end

  def new
    @location = Location.new
  end

  def edit
    @location = Location.find(params[:id])
    @history = changes(@location)
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      record_activity new_obj: @location
      redirect_to locations_path
    else
      render :new
    end
  end

  def update
    @location = Location.find(params[:id])
    old_obj = @location.dup
    if @location.update(location_params)
      record_activity old_obj: old_obj, new_obj: @location
      redirect_to locations_path
    else
      render :edit
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    record_activity old_obj: @location
    redirect_to locations_path
  end

  private

  def location_params
    params.require(:location).permit(:department, :room)
  end
end
