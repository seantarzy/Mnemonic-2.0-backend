class PlaylistsController < ApplicationController
    before_action :authorized, only: [:create, :index, :show]


    def create
        @playlist = Playlist.create(title: playlist_params["title"], description: playlist_params["description"], user: @user)
        if @playlist.valid?
            render json: {
                message: "Playlist created."
            }
        else
            render json: {
                message: "Failed to create new playlist."
            }
        end
    end

    def index
        render json: @user.playlists.all 
    end

    # def show
    #     begin 
    #         @playlist = @user.playlists.find(params[:id])
    #             render json: { 
    #                 playlist: {
    #                     id: @playlist.id,
    #                     title: @playlist.title,
    #                     bookmarks: @playlist.bookmarks
    #                 }
    #             }
    #     rescue
    #         render json: {
    #             message: "Unable to find playlist."
    #         }
    #     end
    # end

    private
  
    def playlist_params
      params.permit(:title, :description)
    end

end