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

  def actor_names
    self.actors.map {|actor| actor.name }
  end

  def genre_names
    self.genres.map {|genre| genre.name }
  end

  def self.find_by_name(name)
    self.all.detect {|movie| movie.name.downcase == name.downcase }
  end

  def views
    View.all.select {|view| view.movie == self}
  end

  def viewers
    self.views.select {|view| view.user }
  end

  def ratings
    views.map {|view| view.rating }
  end

  def avg_rating
    base_rating = ratings.sum.to_f / ratings.length
    (base_rating * 2).round / 2.0
  end

end