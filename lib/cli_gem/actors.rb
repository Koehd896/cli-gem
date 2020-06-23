class CliGem::Actor
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
    @@all.map{|actor| actor.name }
  end
  
  def movies
    CliGem::Movie.all.select do |movie|
      movie.actors.include?(self)
    end
  end

  def self.find_by_name(name)
    self.all.detect {|actor| actor.name.downcase == name.downcase }
  end

  def self.find_or_create_by_name(name)
    find_by_name(name) || self.new(name)
  end

end