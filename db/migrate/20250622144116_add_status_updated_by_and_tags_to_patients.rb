class AddStatusUpdatedByAndTagsToPatients < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :status, :string, default: "active", null: false
    add_column :patients, :updated_by_user_id, :integer
    add_column :patients, :tag_list, :string

    add_foreign_key :patients, :users, column: :updated_by_user_id
  end
end
