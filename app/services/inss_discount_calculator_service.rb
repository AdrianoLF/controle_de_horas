class InssDiscountCalculatorService
  SALARY_CAP = 6101.06
  BRACKETS = [
    { limit: 1045.00, aliquot: 0.075, accumulated_value: 78.37 },
    { limit: 2089.60, aliquot: 0.09, accumulated_value: 94.01 },
    { limit: 3134.40, aliquot: 0.12, accumulated_value: 125.37 },
    { limit: 6101.06, aliquot: 0.14, accumulated_value: 415.33 }
  ].freeze

  def perform(salary)
    capped_salary = [salary, SALARY_CAP].min

    total_contribution = 0
    previous_limit = 0

    BRACKETS.each do |bracket|
      if capped_salary > bracket[:limit]
        total_contribution += bracket[:accumulated_value]
        previous_limit = bracket[:limit]
      else
        taxable_income = capped_salary - previous_limit
        partial_contribution = taxable_income * bracket[:aliquot]
        total_contribution += partial_contribution
        break
      end
    end

    truncate(total_contribution)
  end

  private

  def truncate(value)
    value.to_d.truncate(2).to_f
  end
end
