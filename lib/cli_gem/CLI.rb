class CliGem::Cli
  BASE_URL = "https://www.imdb.com"
  LIST_URL = "https://www.imdb.com/chart/moviemeter/?ref_=nv_mv_mpm"

  MAIN_MENU =  "Main menu - Please choose from the following options:
  'browse' - list all movies
  'browse by genre' - list movies by genre
  'browse by actor' - list movies by actor
  'browse by rating' - list movies by rating
  'recommendation' - get a movie recommendation"

  ERRORS = {
    input: "I'm sorry, that's not a valid command, please try again.",
    movie: "I'm sorry, I can't find that movie, please try again.",
    actor: "I'm sorry, I can't find that actor, please try again.",
    genre: "I'm sorry, I can't find that genre, please try again.",
    rating: "Rating must be a number between 1 and 5, please try again.",
    no_views: "I'm sorry you have not watched a movie yet. Please watch a movie to get personalized recommendations.",
    actor_rec: "There are no other movies with your favorite actor/actress.",
    genre_rec: "There are no other movies with your favorite genre."
  }
  
  PROMPTS = {
    welcome: "Welcome to Movie Assistant! Please enter your name",
    browse_by_genre: "Please enter a genre or enter 'list genres' to see all genres",
    browse_by_actor: "Please enter an actor or enter 'list actors' to see all actors",
    next: "What would you like to do next?
        'exit' - end program
        'main menu - return to main menu",
    rating: "How did you like this movie? Please leave a rating, 1-5",
    recommendation: "What would you like your recommendation to be based on? (select a number)
      1. Your favorite movie
      2. Your favorite actor/actress
      3. Your favorite genre
      4. Users with similar viewing history"
  }

  def initialize
    @list = []
    @keyword = "welcome"
    @output = PROMPTS[:welcome]
    @movie = nil
    @user = nil
  end

  def run
    make_movies
    add_movie_attributes
    make_users
    make_ratings
    input_loop
  end

  def make_movies
    CliGem::Movie.create_from_collection(CliGem::Scraper.get_movies(LIST_URL))
  end

  def add_movie_attributes
    CliGem::Movie.all.each do |movie|
      attribute_hash = CliGem::Scraper.get_attributes(BASE_URL + movie.profile_url)
      if attribute_hash 
        movie.add_attributes(attribute_hash)
      else
        CliGem::Movie.all.delete(movie)
      end
    end
  end

  def make_users
    n = 1
    50.times do
      CliGem::User.new("user#{n}")
      n += 1
    end
  end

  def make_ratings 
    CliGem::Movie.all.each do |movie|
      5.times do
        user = CliGem::User.all.sample
        rating = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0].sample
        CliGem::View.new(movie, user, rating)
      end
    end
  end

  def input_loop
    until @input == "exit"
      display_output
      get_user_input
      get_new_output
    end
    goodbye
  end

  def display_output
    puts @output
  end

  def get_user_input
    @input = gets.strip.downcase
  end

  def get_new_output
    case @keyword
    when "welcome"
      name = @input.capitalize
      @user = CliGem::User.new(name)
      @output = "Hi #{name}. Let's find a movie to watch! \n#{MAIN_MENU}"
      @keyword = "main menu"
    when "main menu"
      case @input
      when "browse"
        @output = display_movies(CliGem::Movie.all)
        @keyword = "movie list"
        @list = CliGem::Movie.all
      when "browse by actor"
        @output = PROMPTS[:browse_by_actor]
        @keyword = "browse by actor prompt"
        @list = nil
      when "browse by genre"
        @output = PROMPTS[:browse_by_genre]
        @keyword = "browse by genre prompt"
        @list = nil
      when "browse by rating"
        ranked_movies = CliGem::Movie.all.sort {|a, b| b.avg_rating <=> a.avg_rating }
        @output = display_movies(ranked_movies)
        @keyword = "movie list"
        @list = ranked_movies
      when "recommendation"
        if @user.views.empty?
          @output = "#{ERRORS[:no_views]} \n#{MAIN_MENU}"
          @keyword = "main menu"
        else
          @output = PROMPTS[:recommendation]
          @keyword = "rec prompt"
        end
      else
        @output = ERRORS[:input]
        @keyword = "main menu"
      end
    when "rec prompt"
      case @input
      when "1"
        @output = play(@user.favorite_rec)
        @keyword = "play"
        @movie = @user.favorite_rec
      when "2"
        if @user.actor_rec
          @output = play(@user.actor_rec)
          @keyword = "play"
          @movie = @user.actor_rec
        else
          @output = ERRORS[:actor_rec]
          @keyword = "rec prompt"
        end
      when "3"
        if @user.genre_rec
          @output = play(@user.genre_rec)
          @keyword = "play"
          @movie = @user.genre_rec
        else
          @output = ERRORS[:genre_rec]
          @keyword = "rec prompt" 
        end
      when "4"
        @output = play(@user.user_rec)
        @keyword = "play"
        @movie = @user.user_rec
      else
        @output = ERRORS[:input]
        @keyword = "rec prompt"
      end
    when "browse by actor prompt"
      if @input == "list actors"
        @output = display_names(CliGem::Actor)
        @keyword = "actor list"
        @list = CliGem::Actor.all
      else
        @keyword = "actor list"
        get_new_output
      end
    when "actor list"
      if /^[\d]+$/.match(@input) && @list[@input.to_i - 1]
        actor = @list[@input.to_i - 1]
        @output = display_movies(actor.movies)
        @keyword = "movie list"
        @list = actor.movies
      elsif CliGem::Actor.find_by_name(@input)
        actor = CliGem::Actor.find_by_name(@input)
        @output = display_movies(actor.movies)
        @keyword = "movie list"
        @list = actor.movies
      else
        @output = ERRORS[:actor]
      end
    when "browse by genre prompt"
      if @input == "list genres"
        @output = display_names(CliGem::Genre)
        @keyword = "genre list"
        @list = CliGem::Genre.all
      else
        @keyword = "genre list"
        get_new_output
      end
    when "genre list"
      if /^[\d]+$/.match(@input) && @list[@input.to_i - 1]
        genre = @list[@input.to_i - 1]
        @output = display_movies(genre.movies)
        @keyword = "movie list"
        @list = genre.movies
      elsif CliGem::Genre.find_by_name(@input)
        genre = CliGem::Genre.find_by_name(@input)
        @output = display_movies(genre.movies)
        @keyword = "movie list"
        @list = genre.movies
      else
        @output = ERRORS[:genre]
      end
    when "movie list"
      if /^[\d]+$/.match(@input) && @list[@input.to_i - 1]
        movie= @list[@input.to_i - 1]
        @output = play(movie)
        @keyword = "play"
        @list = nil
        @movie = movie
      elsif CliGem::Movie.find_by_name(@input)
        movie = CliGem::Movie.find_by_name(@input)
        @output = play(movie)
        @keyword = "play"
        @list = nil
        @movie = movie
      else
        @output = ERRORS[:movie]
      end
    when "play"
      if @input.to_f >= 1 && @input.to_f <= 5
        movie = @movie
        user = @user
        rating = (@input.to_f * 2).round / 2
        CliGem::View.new(movie, user, rating)
        @output = "Your rating for '#{movie.name}' has been recorded
         #{PROMPTS[:next]}"
        @keyword = "next"
      else
        @output = ERRORS[:rating]
      end
    when "next"
      if @input == "main menu"
        @output = MAIN_MENU
        @keyword = "main menu"
      else
        @output = ERRORS[:input]
      end
    end
  end

  def list_movies(movies)
    movies.each.with_index(1) do |movie, index|
      print "#{index}. "
      puts "#{display_movie(movie)}"
      puts "----------------\n" unless index == movies.length 
    end
    puts "\n"
  end
  
  def display_movie(movie)
    puts "#{movie.name}
    Actors: #{movie.actor_names.join(", ")} 
    Genre(s): #{movie.genre_names.join(", ")}
    Rating: #{movie.avg_rating} stars"
  end

  def display_movies(movies)
    list_movies(movies)
    puts "Please select a movie by name or number"
  end
  
  def display_names(class_name)
    class_name.all_names.each.with_index(1) do |name, index|
      puts "#{index}. #{name}"
    end
    puts "Please select #{class_name.to_s} by name or number"
  end

  def list_movies_by_actor(actor)
    list_movies(actor.movies)
  end

  def list_movies_by_genre(genre)
    list_movies(genre.movies)
  end

  def play(movie)
    puts "Now Playing '#{movie.name}'"
    10.times do
      print"."
      sleep(0.5)
    end
    puts "\n #{PROMPTS[:rating]}"
  end

  def goodbye
    puts "Thank you for using Movie Assistant, see you again next time!"
  end

end