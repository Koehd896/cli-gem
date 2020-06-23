class View
  attr_accessor :movie, :user, :rating 

  @@all = []

  def initialize(movie, user, rating)
    @movie, @user, @rating = movie, user, rating
    @@all << self
  end

  def self.all
    @@all
  end
end