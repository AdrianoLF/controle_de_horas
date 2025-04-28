class ProponentFinder
  attr_reader :current_user, :params

  DISCOUNT_GROUPS = {
    first: 1045.00,
    second: 2089.60,
    third: 3134.40,
    fourth: 6101.06
  }.freeze

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end

  def perform
    Proponent.where(user_id: current_user.id)
             .then { |q| filter_by_cpf(q) }
             .then { |q| filter_by_name(q) }
             .then { |q| filter_by_discount_group(q) }
  end

  private

  def filter_by_cpf(scope)
    return scope if cpf.blank?

    scope.where('cpf ILIKE ?', "%#{cpf}%")
  end

  def filter_by_name(scope)
    return scope if name.blank?

    scope.where('name ILIKE ?', "%#{name}%")
  end

  def filter_by_discount_group(scope)
    group = params[:discount_group]&.to_sym
    return scope unless DISCOUNT_GROUPS.key?(group)

    if group == :fourth
      scope.where('salary > ?', DISCOUNT_GROUPS[:third])
    else
      sorted_keys = DISCOUNT_GROUPS.keys
      index = sorted_keys.index(group)
      lower_limit = index.zero? ? 0 : DISCOUNT_GROUPS[sorted_keys[index - 1]]
      upper_limit = DISCOUNT_GROUPS[group]
      scope.where('salary > ? AND salary <= ?', lower_limit, upper_limit)
    end
  end

  def cpf
    params[:cpf]&.strip
  end

  def name
    params[:name]&.strip
  end
end
