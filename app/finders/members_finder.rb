class MembersFinder
  def initialize(params)
    @params = params
  end
  
  def perform
    members = base_scope
    members = filter_by_name(members)
    members = order_by_name(members)
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
end
