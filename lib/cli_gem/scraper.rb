class Scraper
  
  def get_movies
    doc = Nokogiri::HTML(open("https://www.imdb.com/chart/moviemeter/?ref_=nv_mv_mpm"))
    movies = doc.css(".lister-list td")
    puts movies
  end

end