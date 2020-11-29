class Song < ApplicationRecord
    belongs_to :artist
    has_many :lyric_snippets, dependent: :delete_all

    def self.seed_songs(artist_id)
        current_artist = Artist.find(artist_id)
        page_number=1

        if $special_artists.include?(current_artist.name)
            page_cap = 10
        else
        page_cap = 5
        end

        while(page_number <= page_cap) do
            response = RestClient.get("https://genius.com/api/artists/#{artist_id}/songs?page=#{page_number}&sort=popularity")
            response = JSON.parse(response)
            songs = response['response']['songs']
            self.create_songs(songs, artist_id)
            page_number = response['response']['next_page']
            if !page_number
                break
            end
        end
    end

    def self.create_songs(songs, artist_id)

        current_artist = Artist.find(artist_id)
        songs.each do |song|
            if current_artist.songs.length > 75 && !$special_artists.include?(current_artist.name)
                break
            end
            if !Song.find_by(full_title: song["full_title"]) 
                begin
                    puts "Seeding #{song['title']}..."
                    song_url = song['url']
                    lyrics = self.get_lyrics(song_url)
                    if lyrics.length > 11000
                        print "yooo that's too long"
                        next
                    end
                   new_song = Song.create(full_title: song['full_title'], artist_id: artist_id, url: song['url'], image: song["song_art_image_url"], title: song['title'])
                    LyricSnippet.new_song_new_snippets(new_song, lyrics)
                rescue
                    puts "rescued!"
                    next
                end
            end
        end
    end

    def self.get_lyrics(song_url)
      response = RestClient.get(song_url)
      parsed_data = Nokogiri::HTML.parse(response)
      lyrics = parsed_data.css('div.lyrics').text
    end

    def self.get_youtube_id(full_title)
        youtube_search_page = "https://www.youtube.com/results?search_query=#{full_title}"
        response = RestClient.get(URI.encode(youtube_search_page))
        parsed_data = Nokogiri::HTML.parse(response) 
        youtube_id = parsed_data.css('body').to_s.split("watch?v=")[1].split("\"")[0]
        return youtube_id
    end

end
