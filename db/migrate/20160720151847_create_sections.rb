class CreateSections < ActiveRecord::Migration[5.0]
  def change
    create_table :sections do |t|
      t.integer :status, default: 0
      t.references :event, index: true, foreign_key: true
      t.string :title
      t.datetime :event_time
      t.datetime :end_time
      t.integer :price
      t.integer :avaliable, default: 0
      t.integer :bought, default: 0

      t.timestamps
    end
  end
end
