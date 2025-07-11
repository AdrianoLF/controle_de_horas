# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  suspended              :boolean          default(FALSE)
#  super_admin            :boolean          default(FALSE)
#
class User < ApplicationRecord
  # Fazendo isso pra quando precisar logar ou deslogar o user só inserir o token
  devise :database_authenticatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, if: :password_present?

  private

  def password_required?
    !persisted? || !password.nil?
  end

  def password_present?
    password.present?
  end
end
