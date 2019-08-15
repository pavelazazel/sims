class DevicesImportsController < ApplicationController
  def new
    @devices_import = DevicesImport.new
  end

  def create
    @devices_import = DevicesImport.new(params[:devices_import])
    if @devices_import.save
      redirect_to devices_path
    else
      render :new
    end
  end
end
