class Api::V1::UsersController < Api::V1::BaseController
  def my_user
    render json: { record: user.as_json }
  end
  
  def update_my_user
    if user.update(user_params)
      @user = user
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
end