class Users::SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    super
    record_activity new_obj: meta
  end

  # DELETE /resource/sign_out
  def destroy
    record_activity old_obj: meta
    super
  end


  private

  def meta
    user_meta request.user_agent, request.remote_addr
  end
end
