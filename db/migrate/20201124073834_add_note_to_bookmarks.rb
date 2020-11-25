class AddNoteToBookmarks < ActiveRecord::Migration[6.0]
  def change
    add_column :bookmarks, :note, :string
  end
end
