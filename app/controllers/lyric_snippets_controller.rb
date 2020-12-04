class LyricSnippetsController < ApplicationController
    def query
        if params[:order] == "true"
            order = true
        else
            order = false
        end
        if params[:fresh_search] == "true"
            fresh_search = true
        else
            fresh_search = false
        end
        matching_result = LyricSnippet.match_initials_to_lyrics(params[:query], params[:current_snippet_index].to_i, order, params[:artist].to_i, fresh_search)
        render json: matching_result
    end
end
