class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :body_pic
      t.string :status

      t.timestamps
    end
  end
end
