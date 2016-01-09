library(httr)
library(data.table)
library(lubridate)
library(RColorBrewer)
library(ggplot2)
library(gridExtra)
library(plyr)


gameZipFilename <- function(year) paste0("~/blog/data/mlb/gl", year, ".zip")
gameFilename <- function(year) paste0("~/blog/data/mlb/GL", year, ".TXT")

downloadFile <- function(year) {
  # see R packages 'retrosheet' and 'sabremetrics' 
  download.file(paste0("http://www.retrosheet.org/gamelogs/gl",year,".zip"), gameZipFilename(year))
  unzip(gameZipFilename(year), exdir="~/blog/data/mlb/")
}

# get the listing of games for a current year
getGames <- function(year=2015) {
  if(!file.exists(gameFilename(year))) downloadFile(year)
  games <- data.table(read.csv(gameFilename(year), header = FALSE))
  # game key from here: http://www.retrosheet.org/gamelogs/glfields.txt (partial)
  games_key <- c("date", "game_number", "day_of_week", "visiting_team", "visiting_league", "visiting_team_game_number", 
                 "home_team", "home_league", "home_team_game_number", 
                 "visiting_score", "home_score", "game_length_outs")
  colnames(games)[1:length(games_key)] <- games_key
  games[, date := ymd(date)]
  games
}
# let's condense this so it's just scores

getTeamScores <- function(games) {
  scores <- games[, c("date", "visiting_team", "home_team", "visiting_score", "home_score"), with=FALSE]
  # I want each team to get its own table
  team_scores1 <- scores[, list(date=date, team=home_team, score=home_score, opponent=visiting_team, opponent_score=visiting_score)]
  team_scores2 <- scores[, list(date=date, team=visiting_team, score=visiting_score, opponent=home_team, opponent_score=home_score)]
  team_scores <- rbind(team_scores1, team_scores2)
  team_scores <- team_scores[order(date)]
  team_scores[, game_number:=1:nrow(.SD),by=team]
  team_scores[, win := score> opponent_score]
  team_scores[, win_pos_neg := as.numeric(win)*2 -1]
  #team_scores <- team_scores[order(date)]
  team_scores[, win500 := cumsum(win_pos_neg), by=team]
  
  team_scores_daily <- team_scores[, list(win500=last(win500)), by=c("date", "team", "game_number")]
  team_scores_daily[, win500plus := win500]
  team_scores_daily[, win500minus := win500]
  team_scores_daily[win500plus<0, win500plus:=NA]
  team_scores_daily[win500minus>0, win500minus:=NA]
  leagues <- unique(games[, list(team=home_team, league=home_league)])
  team_scores_daily <- merge(team_scores_daily, leagues, by="team")
}

plotTeamScores <- function(team_scores_daily) {
  year <- year(team_scores_daily[1]$date)
  # need to make an 'above 500' and 'below 500' series with zeros all the way across
  p1=ggplot(team_scores_daily[league=="AL"], aes(x=date, y=win500plus, group=team)) + 
    geom_line(color="#2c7bb6", size=1) + geom_line(aes(y=win500minus),color="#d7191c", size=1) +
    facet_wrap(~team, nrow=4) + theme_bw() + geom_hline(aes(yintercept=0)) + ggtitle("AL teams") +
    ylab("Wins above .500") + xlab(paste0(year, " regular season"))+ theme(axis.ticks = element_blank(), axis.text.x = element_blank())
  
  
  p2=ggplot(team_scores_daily[league=="NL"], aes(x=date, y=win500plus, group=team)) + 
    geom_line(color="#2c7bb6", size=1) + geom_line(aes(y=win500minus),color="#d7191c", size=1) +
    facet_wrap(~team, nrow=4) + theme_bw() + geom_hline(aes(yintercept=0)) + ggtitle("NL teams") +
    ylab("Wins above .500")+ xlab(paste0(year, " regular season")) + theme(axis.ticks = element_blank(), axis.text.x = element_blank())
  grid.arrange(p1, p2, ncol = 2)
  
}

plotTeamScoresYear <- function(year) {
  plotTeamScores(getTeamScores(getGames(year)))
  
}

getTeamScoresByYear <- function(team, years) {
  thisteam=team
  data.table(ldply(years, function(year) {
    scores<-getTeamScores(getGames(year))
    scores[, year := year]
    scores[team==thisteam]
  }))
}


