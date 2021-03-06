class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    if user_signed_in?
      @user = User.new(user_params)
      if @user.save
        record_activity new_obj: @user,
                        info: @user.username
        redirect_to users_path
      else
        render :new
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @history = []
    history = UserActivity.where(object_type: 'session',
                                 user_id: @user.id).order("created_at DESC").take(3)
    history.each { |h| @history.append('[' + h.created_at.to_s + '] ' +
                                       h.user.username + ' ' +
                                       h.action + ' ' +
                                       h.object_type +
                                       (h.info.blank? ? '' : ": #{h.info}")) }
  end

  def update
    if current_user.id == params[:id].to_i
      current_user.password = current_user.password_confirmation = params[:password]
      if current_user.update(user_params)
        redirect_to root_path
      else
        render :edit
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    record_activity old_obj: @user,
                    info: @user.username
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :image)
  end
end
