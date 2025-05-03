class EventsFinder
  MAX_RESULTS = 10

  def initialize(params)
    @params = params
  end
  
  def perform
    events = base_scope
    events = filter_by_title(events)
    events = order_by_title(events)
    events = paginate(events)
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

  def paginate(scope)
    max_results = show_all_records? ? 999_999 : MAX_RESULTS
    scope.page(@params[:page].presence || 1).per(max_results)
  end

  def show_all_records?
    @params[:all_records].present?
  end
end
