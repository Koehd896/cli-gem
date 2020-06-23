class CliGem::Genre
  attr_accessor :name

  @@all = []

  def initialize(name)
    @name = name
    @@all << self
  end

  def self.all
    @@all
  end

  def self.all_names
    @@all.map{|genre| genre.name }
  end
  
  def movies
    CliGem::Movie.all.select do |movie|
      movie.genres.include?(self)
    end
  end

  def self.find_by_name(name)
    self.all.detect {|genre| genre.name.downcase == name.downcase }
  end

  def self.find_or_create_by_name(name)
    find_by_name(name) || self.new(name)
  end

end