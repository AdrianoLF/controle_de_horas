class EventsFinder
  def initialize(params)
    @params = params
  end

  def perform
    events = base_scope
    events = filter_by_title(events)
    order_by_created_at(events)
  end

  private

  def base_scope
    Event.all
  end

  def filter_by_title(scope)
    return scope if @params[:title].blank?

    scope.where('title ILIKE ?', "%#{@params[:title]}%")
  end

  def order_by_created_at(scope)
    scope.order(created_at: :desc)
  end
end
