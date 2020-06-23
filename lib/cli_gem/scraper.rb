require "nokogiri"
require "open-uri"

class Scraper

  def self.get_movies(url)
    movies = []
    doc = Nokogiri::HTML(open(url))
    doc.css(".lister-list tr").each do |profile|
      movie = {
        name: profile.css(".titleColumn a").text,
        profile_url: profile.css(".titleColumn a").attribute("href").value
      }
      movies << movie
    end
    movies
  end

  def self.get_attributes(movie_profile_url)
    doc = Nokogiri::HTML(open(movie_profile_url))
    if doc && doc.css(".credit_summary_item")[2]
      actors = doc.css(".credit_summary_item")[2].css("a")[0..2].map do |actor|
        actor.text
      end
      genres = doc.css('.subtext a')[0...-1].map do |genre|
        genre.text
      end
      attritbutes = {
        actors: actors,
        genres: genres
      }
    else
      nil
    end
  end

end