class Api::V1::InssCalculationsController < ApplicationController
  def discount
    salary = params[:salary].to_f
    discount = InssDiscountCalculatorService.new.perform(salary)
    render json: { salary: salary, inss_discount: discount }, status: :ok
  end
end
