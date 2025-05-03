class MembersFinder
  MAX_RESULTS = 10

  def initialize(params)
    @params = params
  end
  
  def perform
    members = base_scope
    members = filter_by_name(members)
    members = order_by_name(members)
    members = paginate(members)
    members
  end

  private

  def base_scope
    Member.all
  end

  def filter_by_name(scope)
    return scope if @params[:name].blank?

    scope.where("name ILIKE ?", "%#{@params[:name]}%")
  end

  def order_by_name(scope)
    scope.order(name: :asc)
  end

  def paginate(scope)
    max_results = show_all_records? ? 999_999 : MAX_RESULTS
    scope.page(@params[:page].presence || 1).per(max_results)
  end

  def show_all_records?
    @params[:all_records].present?
  end
end
