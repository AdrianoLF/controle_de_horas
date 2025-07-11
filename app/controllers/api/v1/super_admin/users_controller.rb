class Api::V1::SuperAdmin::UsersController < Api::V1::SuperAdmin::BaseController
  def index
    scope = build_users_scope
    @users = paginate(scope:, params: permitted_params)
  end

  def update
    @resource = User.find(params[:id])
    @resource.update(permitted_params) || render_error
  end

  def create
    @resource = User.new(permitted_params)
    @resource.save || render_error
  end

  private

  def build_users_scope
    scope = User.order(:name)

    scope = filter_by_name(scope)
    filter_by_status(scope)
  end

  def filter_by_status(scope)
    return scope if permitted_params[:status].blank?

    if permitted_params[:status].present?
      case permitted_params[:status]
      when 'active'
        scope = scope.where(suspended: false)
      when 'suspended'
        scope = scope.where(suspended: true)
      end
    end

    scope
  end

  def filter_by_name(scope)
    return scope if permitted_params[:name].blank?

    search_term = "%#{permitted_params[:name]}%"
    scope.where('name ILIKE ? OR email ILIKE ?', search_term, search_term)
  end

  def permitted_params
    params.permit(:name, :email, :password, :password_confirmation, :super_admin, :suspended,
                  :status, :page, :all_records).compact_blank
  end

  def render_error
    render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
  end
end
