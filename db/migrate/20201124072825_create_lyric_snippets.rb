class CreateLyricSnippets < ActiveRecord::Migration[6.0]
  def change
    create_table :lyric_snippets do |t|
      t.string :snippet
      t.integer :song_id
      t.string :initials
      t.string :sorted_initials

      t.timestamps
    end
  end
end
