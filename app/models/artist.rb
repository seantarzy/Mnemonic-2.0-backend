class Artist < ApplicationRecord
  has_many :songs, dependent: :delete_all
  has_many :lyric_snippets, through: :songs

  $special_artists = ["The Beatles", "Eminem", "Kendrick Lemar", "Drake", "Red Hot Chilli Peppers", ]

  $bogus_artists = ["Music recording sales certification", "Jars of Clay"]
  def self.seed_artist_and_songs(artist_name, genre)
    if Artist.find_by(name: artist_name)
        if (Artist.find_by(name: artist_name).songs.length > 75 &&  !$special_artists.include?(artist_name)) || $bogus_artists.include?(artist_name)
        print "thats enough for this artist"
        return true
        else
        artist = Artist.find_by(name: artist_name)
        end
    else
      artist = self.create_artist(artist_name, genre)
      if artist == "artist not available"
      return true
      end
    end
    puts "Searching for songs by #{artist_name}..."
    Song.seed_songs(artist.id)
  end

  def self.create_artist(artist_name, genre="any")
    begin
    response = RestClient.get("#{@@base_genius_uri}/search?q=#{artist_name}&access_token=#{ENV['GENIUS_API_KEY']}")
    response = JSON.parse(response)
    artist_id = response["response"]["hits"][0]["result"]["primary_artist"]["id"]
    artist_name = response["response"]["hits"][0]["result"]["primary_artist"]["name"]
      Artist.create(name: artist_name, id: artist_id, genre: genre)
    rescue => exception
      return "artist not available"
    end
  end

  
 
  def self.get_songs_by_artist_id(artist_filter)
    if artist_filter != 'any'
      artist = Artist.find(artist_filter)
      return songs = artist.songs
    else
      return songs = Song.all
    end
  end
#old way of quering:

 # def self.make_initials_hash(initials_array)
  #   initials_hash = {}
  #   initials_array.each do |initial|
  #     if initials_hash[initial]
  #     initials_hash[initial] += 1
  #     else 
  #       initials_hash[initial] = 1
  #     end
  #   end
  #   return initials_hash
  # end
  # def self.query_with_order(initials, current_song_index, lyrics, song, song_index)
  #   initials_index = 0
  #   matching_phrase = ''
    
  #   lyrics.each_with_index do |word, index| 
  #     if word[0].upcase === initials[initials_index] && initials_index != initials.length
  #       initials_index += 1
  #       matching_phrase += "#{word} "
  #     elsif initials_index == initials.length
  #       current_song_index += 1
  #       youtube_id = Song.get_youtube_id(song['full_title'])
  #       song = song.attributes
  #       song['youtube_id'] = youtube_id
  #       return {matching_phrase: matching_phrase, song: song, current_song_index: current_song_index + song_index}
  #     else
  #       initials_index = 0
  #       matching_phrase = ''
  #     end
  #   end
  #   return false
  # end
  
  # def self.query_without_order(initials, current_song_index, lyrics, song, song_index)
  #   initials_index = 0
  #   matching_phrase = ''

  #   initials_array = initials.split('')
  #   initials_hash = self.make_initials_hash(initials_array)
  #   initials_hash_2 = initials_hash.clone 

  #   lyrics.each_with_index do |word, index|
  #     if initials_hash_2[word[0].upcase] && initials_hash_2[word[0].upcase] > 0 && initials_index != initials.length 
  #       initials_index += 1
  #       initials_hash_2[word[0].upcase] -= 1
  #       matching_phrase += "#{word} "
  #     elsif initials_index == initials.length 
  #       current_song_index += 1
  #       youtube_id = Song.get_youtube_id(song['full_title'])
  #       song = song.attributes
  #       song['youtube_id'] = youtube_id
  #       return {matching_phrase: matching_phrase, song: song, current_song_index: current_song_index + song_index}
  #     else
  #       initials_index = 0
  #       initials_hash_2 = initials_hash.clone 
  #       matching_phrase = ''
  #     end
  #   end
  #   return false
  # end

  # def self.match_to_lyrics(query, current_song_index, artist_filter = 'any', order)
  #     initials = self.get_initials(query)

  #     # Set songs to array of queryable songs based on artist filter
  #     songs = self.get_songs_by_artist_id(artist_filter)
    
  #     matching_info = false
    
  #     songs[current_song_index..-1].each_with_index do |song, song_index|
  #       lyrics = song['lyrics'].split(' ' || '\n')
  #       if order
  #         matching_info = self.query_with_order(initials, current_song_index, lyrics, song, song_index)
  #       else
  #         matching_info = self.query_without_order(initials, current_song_index, lyrics, song, song_index)
  #       end

  #       if matching_info
  #           matching_info["input_phrase"] = query
  #           return matching_info
  #       end
  #     end

  #   return {error: "No matching text"} 
  # end


  def self.get_response_status(artist_name)
    response = RestClient.get("#{@@base_genius_uri}/search?q=#{artist_name}&access_token=#{ENV['GENIUS_API_KEY']}")
    response = JSON.parse(response)
    status = response["meta"]["status"]
  end

  def self.seed_billboard
    artist_array = []
    page_url = "https://www.billboard.com/charts/year-end/2019/top-artists"
    page = Nokogiri::HTML(open(page_url))
      i = 0
      page_array = page.css('div.chart-details').css('article.ye-chart-item').to_a
      while i < page_array.length do
        artist_array.push(page_array[i].css('div.ye-chart-item__title').text.split("\n\n")[1])
        i += 1
      end

      artist_array.each do |artist_name| 
        status = self.get_response_status(artist_name)
        if status == 200
          self.seed_artist_and_songs(artist_name, "billboard top 100")
        end
      # response = JSON.parse(response)
      end
  end

  def self.seed_top_selling_artists
      page_url = 'https://en.wikipedia.org/wiki/List_of_best-selling_music_artists'
      page = Nokogiri::HTML(open(page_url))
      i = 2
      while i < 250 do 
        artist_name = page.css('tr')[i].to_s.split('title')[1].split('">')[0][2..-1]
        
        if page.css('tr')[4].to_s.split('/wiki/')[2]
          genre = page.css('tr')[i].to_s.split('/wiki/')[2].split("title")[1].split('</a>')[0].split('>')[1]
        else 
          genre = 'any'
        end

        if artist_name.class == String 
          self.seed_artist_and_songs(artist_name, genre)
        end

      i+= 1
     end
  end

end