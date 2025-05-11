class EventsFinder
  def initialize(params)
    @params = params
  end
  
  def perform
    events = base_scope
    events = filter_by_title(events)
    events = order_by_title(events)
    events
  end

  private

  def base_scope
    Event.all
  end

  def filter_by_title(scope)
    return scope if @params[:title].blank?

    scope.where("title ILIKE ?", "%#{@params[:title]}%")
  end

  def order_by_title(scope)
    scope.order(title: :asc)
  end
end
