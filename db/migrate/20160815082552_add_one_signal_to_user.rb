class AddOneSignalToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :onesignal_token, :string
  end
end
