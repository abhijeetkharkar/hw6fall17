class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
  def Movie::create_from_tmdb(tmdb_id)
    details = Tmdb::Movie.detail(tmdb_id)
    ratings = Tmdb::Movie.releases(tmdb_id)["countries"]
    #puts details
    #puts "Title = #{details["title"]}, Release Date = #{details["release_date"]}"
    #puts "Country Rating = #{ratings}"
    movie_hash = Hash.new
    movie_hash = {:title => details["title"], :release_date => details["release_date"], :description => details["overview"]}
    ratings.each do |country_rating| 
      if country_rating["iso_3166_1"] == "US"
        movie_hash[:rating] = country_rating["certification"]
        break
      end
    end
    Movie.create(movie_hash)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      @matching_movies = Tmdb::Movie.find(string)
      puts "Matching Movies = #{@matching_movies}"
      temp = []
      if @matching_movies == nil || @matching_movies.count == 0
        return temp
      end
      puts @matching_movies
      puts "Results => Title : #{@matching_movies[0].title}, Release Date : #{@matching_movies[0].release_date}"
      puts "Rating => #{Tmdb::Movie.releases(@matching_movies[0].id)}"
      @matching_movies.each do |movie| 
        movie_hash = Hash.new
        movie_hash = {:tmdb_id => movie.id, :title => movie.title, :release_date => movie.release_date}
        @ratings = Tmdb::Movie.releases(movie.id)["countries"]
        @ratings.each do |country_rating| 
          if country_rating["iso_3166_1"] == "US"
            if country_rating["certification"] == ""
              movie_hash[:rating] = "NR"
            else
              movie_hash[:rating] = country_rating["certification"]
            end
            break
          end
        end
        if movie_hash[:rating] == nil
          movie_hash[:rating] = "NR"
        end
        puts "Movie Hash = #{movie_hash}"
        temp.push(movie_hash)
      end
      @matching_movies = temp
      puts "Matching Movies Final = #{@matching_movies}"
      return @matching_movies
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end

end
