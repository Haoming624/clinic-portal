class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :name
      t.date :dob
      t.text :notes

      t.timestamps
    end
  end
end
