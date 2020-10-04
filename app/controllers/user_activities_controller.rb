require "#{Rails.root}/lib/filter.rb"

class UserActivitiesController < ApplicationController
  def index
    @users_all = User.all.order(username: :asc)
    @actions_all = ['create', 'update', 'destroy'].sort
    @object_types_all = ['brand', 'consumable_type', 'consumable', 'consumable_movement',
                         'device', 'location', 'name', 'type', 'session', 'database'].sort
    @filter_params = filter_params
    if @filter_params.blank?
      @user_activities = UserActivity.all.order(id: :desc)
    else
      @user_activities = filter(UserActivity.order(id: :desc), @filter_params)
    end
    @user_activities = @user_activities.paginate(page: params[:page])
  end


  private

  def filter_params
    return if params[:filter].blank?
    params.require(:filter).permit(:object_id, :date_from, :date_to,
                                   user_ids: [], actions: [], object_types: [])
  end

  def filter(scope, params)
    Filter.new(scope, params).call
  end

end
