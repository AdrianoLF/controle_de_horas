class MembersFinder
  def initialize(params)
    @params = params
    @active = @params[:active]
    @name = @params[:name]
    @team_ids = @params[:team_ids]
    @sort_by = @params[:sort_by] || 'name'
    @sort_order = @params[:sort_order] || 'asc'
  end

  def perform
    members = base_scope
    members = filter_by_name(members)
    members = filter_by_active(members)
    members = filter_by_teams(members)
    apply_sorting(members)
  end

  private

  def base_scope
    Member.all
  end

  def filter_by_name(scope)
    return scope if @name.blank?

    scope.where('members.name ILIKE ?', "%#{@name}%")
  end

  def filter_by_active(scope)
    return scope if @active.nil?

    # Converte string para boolean se necessário
    active_value = case @active.to_s.downcase
                   when 'true', '1'
                     true
                   when 'false', '0'
                     false
                   else
                     return scope
                   end

    scope.where(members: { active: active_value })
  end

  def filter_by_teams(scope)
    return scope if @team_ids.blank?

    team_ids = Array.wrap(@team_ids).map(&:to_i)
    scope.joins(:teams).where(teams: { id: team_ids }).distinct
  end

  def apply_sorting(scope)
    case @sort_by
    when 'name'
      scope.order('members.name' => sort_direction)
    when 'created_at'
      scope.order('members.created_at' => sort_direction)
    else
      scope.order('members.name' => :asc)
    end
  end

  def sort_direction
    @sort_order == 'desc' ? :desc : :asc
  end
end
