class BookmarksController < ApplicationController
    before_action :authorized, only: [:create, :index, :destroy, :update]

    def create
        @bookmark = Bookmark.create(bookmark_params)

        if @bookmark.valid?
            render json: { message: "Bookmark created." }
        else
            render json: { message: "Failed to create new bookmark" }
        end 
    end

    def index
        render json: { bookmarks: @user.bookmarks }
    end
    
    def destroy
        Bookmark.find(params[:id]).destroy()
    end

    def show
       bookmark = Bookmark.find(params[:id])
       render json: bookmark
    end
    def update
       bookmark = Bookmark.find(params[:bookmark_id])
       bookmark.update_attribute(:note, params[:note])
    end
    
    private
  
    def bookmark_params
      params.require(:bookmark).permit(:playlist_id, :song_id, :input_phrase, :matching_phrase, :youtube_id)
    end

end
