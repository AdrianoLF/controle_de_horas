class AddRoleToMembership < ActiveRecord::Migration[7.0]
  def change
    add_column :memberships, :role, :integer, default: 0
  end
end
