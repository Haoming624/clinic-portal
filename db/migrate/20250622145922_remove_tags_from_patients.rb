class RemoveTagsFromPatients < ActiveRecord::Migration[8.0]
  def change
    remove_column :patients, :tag_list, :string
  end
end
