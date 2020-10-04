class Filter

  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def call
    filter_by_user_ids
    filter_by_actions
    filter_by_object_types
    filter_by_object_id
    filter_by_date_from
    filter_by_date_to

    @scope
  end


  private

  def filter_by_user_ids
    return if @params[:user_ids].blank?
    @scope = @scope.where(user_id: @params[:user_ids])
  end

  def filter_by_actions
    return if @params[:actions].blank?
    @scope = @scope.where(action: @params[:actions])
  end

  def filter_by_object_types
    return if @params[:object_types].blank?
    @scope = @scope.where(object_type: @params[:object_types])
  end

  def filter_by_object_id
    return if @params[:object_id].blank?
    @scope = @scope.where(object_id: @params[:object_id])
  end

  def filter_by_date_from
    return if @params[:date_from].blank?
    @scope = @scope.where("created_at > ?", DateTime.parse(@params[:date_from]))
  end

  def filter_by_date_to
    return if @params[:date_to].blank?
    @scope = @scope.where("created_at < ?", DateTime.parse(@params[:date_to]))
  end

end
