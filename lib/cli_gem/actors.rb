class Actor
  attr_accessor :name
  attr_reader :movies

  @@all = []

  def initialize(name)
    @name = name
    @movies = []
    @@all << self
  end

  def self.all
    @@all
  end
  
  def movies
    Movie.all.select do |movie|
      movie.actors.include?(self)
    end
  end

  def self.find_by_name(name)
    self.all.detect {|actor| actor.name == name }
  end

  def self.find_or_create_by_name(name)
    find_by_name(name) || self.new(name)
  end

end