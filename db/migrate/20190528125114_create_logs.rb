class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.string :title
      t.string :public_id
      t.string :image
      t.string :content

      t.timestamps
    end
  end
end
