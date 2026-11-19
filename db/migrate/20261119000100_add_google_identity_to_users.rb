class AddGoogleIdentityToUsers < ActiveRecord::Migration[8.1]
  def up
    change_column_null :users, :location, true
    add_column :users, :google_uid, :string
    add_index :users, :google_uid, unique: true
  end

  def down
    remove_column :users, :google_uid
    change_column_null :users, :location, false, ""
  end
end
