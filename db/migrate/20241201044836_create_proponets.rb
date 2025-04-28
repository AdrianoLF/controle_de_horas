class CreateProponets < ActiveRecord::Migration[7.0]
  def change
    create_table :proponents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false, index: true
      t.string :cpf, null: false, index: true
      t.date :birth_date, null: false
      t.jsonb :address
      t.jsonb :phones
      t.decimal :salary, precision: 15, scale: 2, null: false
      t.decimal :inss_discount, precision: 15, scale: 2, null: false

      t.timestamps
    end

    add_index :proponents, %i[user_id cpf], unique: true
  end
end
