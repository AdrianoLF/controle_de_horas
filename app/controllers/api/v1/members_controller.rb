class Api::V1::MembersController < ApplicationController
  def show
    render json: { user: user }
  end
end
