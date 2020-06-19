class Cli
    attr_accessor :input, :output, :list
  BASE_URL = "https://www.imdb.com"
  LIST_URL = "https://www.imdb.com/chart/moviemeter/?ref_=nv_mv_mpm"

  MAIN_MENU =  "Welcome to Movie Assistant! Please choose from the following options:
  'browse' - list all movies
  'browse by genre' - list movies by genre
  'browse by actor' - list movies by actor"
  #   ALL_MOVIES = display_movies(Movie.all)
#   ALL_ACTORS = display_names(Actor.all)
#   ALL_GENRES = display_names(Genre.all)
  ERRORS = {
    input: "I'm sorry, that's not a valid command, please try again.",
    movie: "I'm sorry, I can't find that movie, please try again.",
    number: "I'm sorry, that is not a valid number, please try again."
  }
  PROMPTS = {
    browse_by_genre: "Please enter a genre or enter 'list genres' to see all genres",
    browse_by_actor: "Please enter an actor or enter 'list actors' to see all actors",
    next: "What would you like to do next?
        'exit' - end program
        'main menu - return to main menu" 
  }
#   CONDITIONS = {
#     main_menu: ["browse", "browse by actor", "browse by genre"].any?(@input)
#   }


#   pattern:
#   display(optional)
    #   could be:
    #   -prompt
    #   -menu/list
#   get user input:
    #   could be:
    #   -command
    #   -prompt
#   validate user input
    #   validate method loops until condition is met and returns argument for next method?
    #   
#   generate arguments for next method
#   call next method based on user input
    #   have case statement with validated input to call next method


  def initialize
    @list = []
    @keyword = "main menu"
    @output = MAIN_MENU
  end

  def run
    make_movies
    add_all_attributes
    input_loop
  end

  def make_movies
    Movie.create_from_collection(Scraper.get_movies(LIST_URL))
  end

  def add_all_attributes
    Movie.all.each do |movie|
      attribute_hash = Scraper.get_attributes(BASE_URL + movie.profile_url)
      movie.add_attributes(attribute_hash)
    end
  end

  def input_loop
    display_output
    get_user_input
    until @input == "exit"
      validate_input
      get_new_output
      input_loop
    end
    goodbye
  end

  def display_output
    puts @output
  end

#   def greet
#     puts "Welcome to Movie Assistant! Please choose from the following options:"
#     main_menu
#   end

#   def main_menu
#     puts "
#     'browse' - list all movies
#     'browse by genre' - list movies by genre
#     'browse by actor' - list movies by actor"
#     main_menu_choice
#   end

  def get_user_input
    @input = gets.strip.downcase
  end

  def validate_input
    case @keyword
    when "main menu"
      unless ["browse", "browse by actor", "browse by genre"].any?(@input)
        @output = ERRORS[:input]
        input_loop
      end
    when "browse by actor prompt"
      unless @input == "list actors" || Actor.find_by_name(@input)
        @output = ERRORS[:input]
        input_loop
      end
    when "browse by genre prompt"
      unless @input == "list genres" || Genre.find_by_name(@input)
        @output = ERRORS[:input]
        input_loop
      end
    when "movie list"
      unless @list[@input.to_i - 1] || @list.any?{|movie| movie.name.downcase == @input }
        @output = ERRORS[:movie]
        input_loop
      end
    when "play"
      unless @input == 'main menu' || @input == "exit"
        @output = ERRORS[:input]
        input_loop
      end
    end

    
  end

  def get_new_output
    case @keyword
    when "main menu"
      case @input
      when "browse"
        @output = display_movies(Movie.all)
        @keyword = "movie list"
        @list = Movie.all
      when "browse by actor"
        @output = PROMPTS[:browse_by_actor]
        @keyword = "browse by actor prompt"
        @list = nil
      when "browse by genre"
        @output = PROMPTS[:browse_by_genre]
        @keyword = "browse by genre prompt"
        @list = nil
      end
    when "browse by actor prompt"
      if @input == "list actors"
        @output = display_names(Actor)
        @keyword = "browse by actor prompt"
        @list = Actor.all
      else
        actor = Actor.find_by_name(@input)
        @output = display_movies(actor.movies)
        @keyword = "movie list"
        @list = actor.movies
      end
    when "browse by genre prompt"
      if @input == "list genres"
        @output = display_names(Genre)
        @keyword = "browse by genre prompt"
        @list = Genre.all
      else
        genre = Genre.find_by_name(@input)
        @output = display_movies(genre.movies)
        @keyword = "movie list"
        @list = genre.movies
      end
    when "movie list"
      if /^[\d]+$/.match?(@input)
        @output = play(@list[@input.to_i - 1])
        @keyword = "play"
        @list = nil
      else
        @output = play(Movie.find_by_name(@input))
        @keyword = "play"
        @list = nil
      end
    when "play"
      @output = MAIN_MENU
      @keyword = "main menu"
      @list = nil
    end

  end

#   def main_menu_choice
#     get_user_input
#     commands = ["browse", "browse by actor", "browse by genre"]
#     until commands.any?(@input)
#       error("Sorry, that is not a valid command, please try again", "main_menu_choice")
#     end
#     case @input
#     when "browse" then browse
#     when "browse by actor" then browse_by(Actor)
#     when "browse by genre" then browse_by(Genre)
#     end
#   end

#   def browse
#     display_movies(Movie.all)
#     select(Movie, Movie.all)
#   end

#   def browse_by(class_name)
#     puts "Please enter a #{class_name.to_s} or enter 'list #{class_name.to_s}s' to see all #{class_name.to_s}s"
#     get_user_input
#     if @input == "list #{class_name.to_s}s".downcase
#       display_names(class_name)
#       criteria = select(class_name, class_name.all)
#     else
#       until class_name.find_by_name(@input)
#       puts "Sorry, I can't find that #{class_name.to_s}, please try again"
#       get_user_input
#       end
#       criteria = class_name.find_by_name(@input)
#     end
#     display_movies(criteria.movies)
#     movie_selection = select(class_name, criteria.movies)
#     play(movie_selection)
#   end

#   def browse_by_actor
#     puts "Please enter an actor"
#     get_user_input
#     actor = Actor.find_by_name(@input)
#     if actor
#       display_movies(actor.movies)
#       select_movie(actor.movies)
#     else
#       error("Sorry, I can't find that actor, please try again", "main_menu_choice")
#     end
#   end

#   def error(error_message, method_name, *args)
#     puts error_message
#     args.length > 0 ? send(method_name, args) : send(method_name)
#   end

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
    Genre(s): #{movie.genre_names.join(", ")}"
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

#   def select(class_name, collection)
#     get_user_input
#     if /^[\d]+$/.match?(@input)
#       criteria = collection[@input.to_i - 1]
#       unless criteria
#        error("Sorry, that is not a valid number, please try again", "select", class_name.to_s, collection)
#       end
#     else
#       criteria = class_name.find_by_name(@input) 
#       unless criteria
#         error("Sorry, I can't find that #{class_name.to_s}, please try again", "select", class_name.to_s, collection)
#       end
#     end
#     criteria
#    end

   def play(movie)
     puts "Now Playing '#{movie.name}'"
     10.times do
       print"."
       sleep(0.5)
     end
     puts "\n #{PROMPTS[:next]}"
   end

   def goodbye
     puts "Thank you for using Movie Assistant, see you again next time!"
   end


end