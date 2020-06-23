class CliGem::User
  attr_accessor :name

  @@all = []

  def initialize(name)
    @name = name
    @@all << self
  end

  def self.all
    @@all
  end

  def views
    CliGem::View.all.select {|view| view.user == self}
  end

  def watched
    self.views.map {|view| view.movie }
  end

  def favorite_movie
    self.watched.sort {|a, b| a.avg_rating <=> b.avg_rating }.last
  end

  def favorite_rec
    top_ranked = CliGem::Movie.all.sort {|a, b| b.avg_rating <=> a.avg_rating }.find do |movie|
      !self.watched.include?(movie)
    end
    self.actor_rec || self.genre_rec || top_ranked
  end

  def actor_rec
    recs = self.favorite_movie.actors.map do |actor|
      actor.movies.select {|movie| !self.watched.include?(movie) }
    end
    recs.flatten[0]
  end

  def genre_rec
    recs = self.favorite_movie.genres.map do |genre|
      genre.movies.select {|movie| !self.watched.include?(movie) }
    end
    recs.flatten[0]
  end

  def user_rec
    rec_user = CliGem::User.all.find {|user| user.watched.include?(self.favorite_movie) }
    rec_user.watched.find {|movie| !self.watched.include?(movie) }
  end

end