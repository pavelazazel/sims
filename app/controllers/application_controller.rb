class ApplicationController < ActionController::Base

  include ActivityLoggable

  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  before_action :authenticate_user!


  protected

  def changes obj
    last_changes(obj)
  end

  def record_activity old_obj: nil, new_obj: nil, action: nil,
                      object_type: nil, object_id: nil, info: nil
    activity = UserActivity.new
    activity.attributes = { user_id: current_user.id,
                            action: action || action_name,
                            object_type: object_type || controller_name.singularize,
                            object_id: object_id || (new_obj || old_obj).id,
                            info: info || changes_info(old_obj, new_obj) }
    activity.save
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
