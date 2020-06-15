class Movie
  attr_accessor :name, :profile_url
  attr_reader :actors, :genres

  @@all = []

  def initialize(movie_hash)
    movie_hash.each do |key, value|
      self.send("#{key}=", value)
    end
    @actors = []
    @genres = []
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_from_collection(movies_array)
    movies_array.each do |movie|
      self.new(movie)
    end
  end

  def add_attributes(attribute_hash)
    attribute_hash.each do |key, value_array|
      value_array.each do |value|
        self.send("#{key}=", value)
      end
    end
  end

  def genres=(genre)
    @genres << Genre.find_or_create_by_name(genre)
  end

  def actors=(actor)
    @actors << Actor.find_or_create_by_name(actor)
  end

  def self.list_movies(movies)
    movies.each.with_index(1) do |movie, index|
      puts "#{index}. #{movie.display_movie}"
      puts "----------------" unless index == movies.length 
    end
  end
  
  def display_movie
    puts "#{self.name}
    Actors: #{self.actors.join(", ")} 
    Genre(s): #{self.genres.join(", ")}"
  end

  def self.display_movies_by_actor(actor)
    self.list_movies()
  end

end