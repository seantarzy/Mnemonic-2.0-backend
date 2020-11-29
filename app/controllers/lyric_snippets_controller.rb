class LyricSnippetsController < ApplicationController
    def query
        initials = Artist.get_initials(params[:query])

        if params[:order] == "true"
            order = true
        else
            order = false
        end
        matching_result = LyricSnippet.match_initials_to_lyrics(params[:query], params[:current_snippet_index].to_i, order, params[:artist].to_i)
        render json: matching_result
    end
end
