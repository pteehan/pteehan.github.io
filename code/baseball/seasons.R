library(httr)
library(data.table)
library(lubridate)
library(RColorBrewer)
library(ggplot2)
library(gridExtra)
library(plyr)
library(memoise)
library(retrosheet)

dataFolder <- "../data/"

# get the listing of games for a current year
getGamesFromWeb <- function(year=2015) {
  g<-data.table(getRetrosheet("game", year))
  g[, Date := ymd(Date)]
  g
}
getGames <- function(years=2015) {
  data.table(ldply(years, function(year) {
  filename <- paste0(dataFolder, "games", year, ".RDS")
  if(file.exists(filename))
    readRDS(filename)
  else
    saveRDS(getGamesFromWeb(year), filename)
  }))
}
# let's condense this so it's just scores

getTeamScores <- function(games) {
  scores <- games[, c("Date", "VisTm", "HmTm", "VisRuns", "HmRuns", "NumOuts"), with=FALSE]
  # I want each team to get its own table
  team_scores1 <- scores[, list(date=Date, team=HmTm, runs_scored=HmRuns, opponent=VisTm, runs_allowed=VisRuns, length_innings=NumOuts/6)]
  team_scores2 <- scores[, list(date=Date, team=VisTm, runs_scored=VisRuns, opponent=HmTm, runs_allowed=HmRuns, length_innings=NumOuts/6)]
  
  team_scores <- rbind(team_scores1, team_scores2)
  team_scores <- team_scores[order(date)]
  team_scores[, game_number:=1:nrow(.SD),by=team]
  team_scores[, win := runs_scored> runs_allowed]
  team_scores[, win_pos_neg := as.numeric(win)*2 -1]
  team_scores[, runs_scored_per_inning := runs_scored/length_innings]
  team_scores[, runs_allowed_per_inning := runs_allowed/length_innings]
  #team_scores <- team_scores[order(date)]
  team_scores[, win500 := cumsum(win_pos_neg), by=team]
  
  team_scores_daily <- team_scores[, list(win500=last(win500)), by=c("date", "team", "game_number", "runs_scored", "runs_allowed", "length_innings")]
  team_scores_daily[, win500plus := win500]
  team_scores_daily[, win500minus := win500]
  team_scores_daily[win500plus<0, win500plus:=NA]
  team_scores_daily[win500minus>0, win500minus:=NA]
  leagues <- unique(games[, list(team=HmTm, league=HmTmLg)])
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


getGamesByYear <- function(years) {
  data.table(ldply(years, function(year) {
    scores<-getGames(year)
    scores[, year := year]
    scores
  }))  
}

getTeamScoresByYear <- function(years, teams=NULL) {
  data.table(ldply(years, function(year) {
    scores<-getTeamScores(getGames(year))
    scores[, year := year]
    if(!is.null(teams))
      scores<-scores[team %in% teams]
    scores
  }))
}


