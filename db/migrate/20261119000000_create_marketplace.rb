class CreateMarketplace < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :location, null: false
      t.string :contact_email
      t.text :bio
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :products do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.boolean :available, null: false, default: true
      t.string :product_url
      t.timestamps
    end
    add_index :products, [:available, :category]
    add_check_constraint :products, "price_cents BETWEEN 1 AND 99999", name: "valid_product_price"
  end
end
