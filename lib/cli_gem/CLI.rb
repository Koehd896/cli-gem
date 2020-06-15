class Cli
  BASE_URL = "https://www.imdb.com"
  LIST_URL = "https://www.imdb.com/chart/moviemeter/?ref_=nv_mv_mpm"

  def run
    make_movies
    add_all_attributes
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

end