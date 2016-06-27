require "watchergg/version"
require "watir-webdriver"
require "nokogiri"

module Watchergg
  def self.get_user(search_query)
    battletag = search_query.split("#")
    battletag_name = battletag[0]
    battletag_numbers = battletag[1]

    profile_url = "https://watcher.gg/profile/pc/us/#{battletag_name}%23#{battletag_numbers}"
    browser = Watir::Browser.new(:phantomjs)
    browser.goto(profile_url)

    # wait for page to load
    until browser.div(:class => "identity").exists? do 
      sleep 1 
    end

    page = Nokogiri::HTML.parse(browser.html)

    {
      :name => page.css(".identity .name").text.strip,
      :portrait => "https" + page.css(".identity .portrait img").attr("src").value,
      :level => page.css(".identity .level").text.strip.to_i,
      :career_stats => create_career_stats(page.css(".career tr")),
      :achievements => create_achievements(page.css(".achievements li")),
      :hero_stats => create_hero_stats(page.css(".hero-cards .hero"))
    }
  end

  def self.create_career_stats(career_stats_node)
    {
      :winrate_percent => career_stats_node[0].css(".value").text.to_f / 100,
      :games_won => career_stats_node[0].css(".win").text.to_i,
      :games_lost => career_stats_node[0].css(".loss").text.to_i,
      :average_score => career_stats_node[1].css(".value").text.to_f,
      :kda => career_stats_node[2].css(".value").text.to_f,
      :time_played => career_stats_node[3].css(".value").text.to_s,
      :medals_total => career_stats_node[4].css(".value").text.to_i,
      :medals_gold => career_stats_node[5].css(".value").text.to_i,
      :medals_silver => career_stats_node[6].css(".value").text.to_i,
      :medals_bronze => career_stats_node[7].css(".value").text.to_i,
      :best_elims => career_stats_node[8].css(".value").text.to_i,
      :best_damage => career_stats_node[9].css(".value").text.gsub!(/\,/,"").to_i,
      :best_healing => career_stats_node[10].css(".value").text.gsub!(/\,/,"").to_i,
      :damage_dealt => career_stats_node[11].css(".value").text.to_f,
      :healing_done => career_stats_node[12].css(".value").text.to_f,
      :eliminations => career_stats_node[13].css(".value").text.to_f,
      :multi_kills => career_stats_node[14].css(".value").text.to_i,
      :objective_kills => career_stats_node[15].css(".value").text.gsub!(/\,/,"").to_i
    }
  end

  def self.create_achievements(achievements_node)
    achievements = []

    achievements_node.each do |achievement|
      achievements.push({
        :name => achievement.css(".name").text.strip,
        :icon => "https" + achievement.css(".icon img").attr("src").value,
        :description => achievement.css(".description").text.strip,
        :points => achievement.css(".points").text.strip.to_i,
      })
    end

    achievements
  end

  def self.create_hero_stats(hero_stats_node)
    hero_stats = []

    hero_stats_node.each do |hero_card|
      hero_stats.push({
        :name => hero_card.css(".name").text.strip,
        :portrait => "https" + hero_card.css(".portrait img").attr("src").value,
        :winrate_percent => hero_card.css(".win-rate .small").text.strip.to_f / 100,
        :games_won => hero_card.css(".win-rate .sub em")[0].text.strip.to_i,
        :games_lost => hero_card.css(".win-rate .sub em")[1].text.strip.to_i,
        :medals_total => hero_card.css(".medals .count").text.strip.to_i,
        :medals_gold => hero_card.css(".medals .medal.gold").text.strip.to_i,
        :medals_silver => hero_card.css(".medals .medal.silver").text.strip.to_i,
        :medals_bronze => hero_card.css(".medals .medal.bronze").text.strip.to_i,
        :kda => hero_card.css(".micro-stats li")[0].css("strong")[0].text.strip.to_f,
        :best_damage => hero_card.css(".micro-stats li")[1].css("strong")[0].text.strip.gsub!(/\,/,"").to_i,
        :best_elims => hero_card.css(".micro-stats li")[2].css("strong")[0].text.strip.to_i,
        :accuracy => hero_card.css(".micro-stats li")[3].css("strong")[0].text.strip.to_f / 100,
        :average_score => hero_card.css(".micro-stats li")[4].css("strong")[0].text.strip.to_f,
        :time_played => hero_card.css(".micro-stats li")[5].css("strong")[0].text.strip.gsub!(/\~/,"").to_i
      })
    end

    hero_stats
  end
end
