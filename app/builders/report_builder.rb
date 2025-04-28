class ReportBuilder
  DISCOUNT_GROUPS = {
    first: 1045.00,
    second: 2089.60,
    third: 3134.40,
    fourth: 6101.06
  }.freeze

  def initialize(current_user)
    @current_user = current_user
  end

  def report_by_discount_group
    group_expression = discount_group_expression

    Proponent.where(user_id: @current_user.id)
             .group(Arel.sql(group_expression))
             .count
             .transform_keys(&:to_sym)
  end

  private

  def discount_group_expression
    <<-SQL.squish
      CASE
        WHEN salary > #{DISCOUNT_GROUPS[:third]} THEN 'fourth'
        WHEN salary > #{DISCOUNT_GROUPS[:second]} AND salary <= #{DISCOUNT_GROUPS[:third]} THEN 'third'
        WHEN salary > #{DISCOUNT_GROUPS[:first]} AND salary <= #{DISCOUNT_GROUPS[:second]} THEN 'second'
        ELSE 'first'
      END
    SQL
  end
end
