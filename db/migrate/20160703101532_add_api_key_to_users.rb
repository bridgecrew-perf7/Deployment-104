class AddApiKeyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :token, :string
  end
end