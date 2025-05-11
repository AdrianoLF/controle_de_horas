class Api::V1::BaseController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user
  before_action :check_suspended_user

  private
  
  def authenticate_user
    unless user
      render json: { error: "Não foi possível autenticar o usuário baseado no token fornecido." }, status: :unauthorized
    end
  end

  def check_suspended_user
    if user.suspended
      render json: { error: "Sua conta está suspensa. Por favor, contate o administrador." }, status: :unauthorized
    end
  end
end
