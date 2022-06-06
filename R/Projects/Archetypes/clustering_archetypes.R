# Author: Cale Williams
# Last Updated: 06/02/2022

# Clear workspace and set seed.
rm(list = ls())
set.seed(55)

setwd('C:/Users/caler/Documents/MyProjects/NBA/R/Projects/Archetypes')

# Import libraries.
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggrepel)
library(bballR)

# DATA --------------------------------------------------------------------

# Retrieve all players.
# There are some mistakes. Some identically named players incorrectly
# have identical PlayerId values assigned.
players.raw <- scrape_all_players()

# Remove ALL duplicate values.
players <- players.raw[!(duplicated(players.raw$PlayerId)
                         | duplicated(players.raw$PlayerId,
                                      fromLast = TRUE)), ]


# # Show players with mistakenly identical IDs.
# identical.id <- data.frame(table(players$PlayerId))
# identical.id[identical.id$Freq > 1,]
# 
# # Fix these manually.
# players[274, 'PlayerId'] <- 'brownde03'
# players[614, 'PlayerId'] <- 'ewingpa02'
# players[1011, 'PlayerId'] <- 'jamesmi02'
# players[1050, 'PlayerId'] <- 'johnsch04'
# players[1405, 'PlayerId'] <- 'mitchto02'
# players[2169, 'PlayerId'] <- 'willibr03'
# players[2188, 'PlayerId'] <- 'willima04'
# players[2231, 'PlayerId'] <- 'wrighch02'

# # Show players with mistakenly identical IDs.
# identical.id <- data.frame(table(players$PlayerId))
# identical.id[identical.id$Freq > 1,]

# Remove players who ended careers prior to 2000.
# players <- players[players$To >= 2000, ]

# Convert height to decimal value.
players$Height <- round(as.numeric(substr(players$Ht, 1, 1))
                        + as.numeric(sub('.*-', '', players$Ht)) / 12,
                        digits = 2)

per100 <- data.frame()

# For each season...
for (i in seq(2011, 2022)) {
  
  # Scrape per 100 stats.
  per100.i <- scrape_season_per_100_poss(i)
  
  # Remove duplicate player rows except first instance.
  # This covers players who were traded and have multiple entries.
  per100.i <- per100.i[!duplicated(per100.i$PlayerId), ]
  
  per100 <- rbind(per100, per100.i)
  
  per100.i <- data.frame()
  
}

# Filter low volume seasons.
per100 <- per100[(per100$G >= 20) & (per100$MP >= 200), ]

# Attach height.
# Remove efficiency stats.
# Remove rows without Height values.
per100 <- per100 %>%
  left_join(players[, c('PlayerId', 'Height')], by = 'PlayerId') %>%
  select(-c('3P%', 'FT%', '2P%')) %>%
  drop_na(Height)

# Improve this.
# Scale data, grouped by season.
per100.scaled <- per100 %>%
  group_by(Season) %>%
  mutate(FG = scale(FG),
         FGA = scale(FGA),
         `3P` = scale(`3P`),
         `3PA` = scale(`3PA`),
         `2P` = scale(`2P`),
         `2PA` = scale(`2PA`),
         FT = scale(FT),
         FTA = scale(FTA),
         ORB = scale(ORB),
         DRB = scale(DRB),
         TRB = scale(TRB),
         AST = scale(AST),
         STL = scale(STL),
         BLK = scale(BLK),
         TOV = scale(TOV),
         PF = scale(PF),
         PTS = scale(PTS),
         Height = scale(Height))

rm(list = c('i', 'per100.i'))

# PRINCIPAL COMPONENT ANALYSIS --------------------------------------------

# Select features to include.
features <- c(13:18, 21:25, 27)

# Perform principal component analysis.
pca <- prcomp(per100.scaled[, features])
summary(pca)

elbow.pca <- data.frame(pc = seq(1, length(summary(pca)[[6]][3, ])),
                        var.prop = summary(pca)[[6]][3, ])

ggplot(data = elbow.pca,
       aes(x = pc,
           y = var.prop)) +
  geom_point(color = '#002b36') +
  geom_line(color = '#002b36') +
  xlab('Principal Component') +
  ylab('Cumulative Proportion of Variance') +
  theme_solarized_2()

# Select number of principal components to use.
pc <- 2

# K-MEANS CLUSTERING ------------------------------------------------------

# Run varying number of centers.
kmeans.all <- c()
k.all <- seq(1, 25)

# For each number of centers...
for (i in k.all) {

  # Run k-means clustering.
  kmeans.all[[(length(kmeans.all) + 1)]] <- kmeans(x = pca$x[, 1:pc],
                                                   centers = i,
                                                   nstart = 20,
                                                   iter.max = 50)
  
}

# Create dataframe of k and associated tot.withinss.
dist <- data.frame(k = k.all,
                   dist = sapply(kmeans.all, '[[', 5))

ggplot(data = dist,
       aes(x = k.all,
           y = dist)) +
  geom_point(color = '#002b36') +
  geom_line(color = '#002b36') +
  xlab('k Clusters') +
  ylab('Total Within SS Distance') +
  theme_solarized_2()

# Select cluster centers.
k <- 10

PC.centers <- data.frame(cluster = seq(1, k),
                         centers = kmeans.all[[k]]$centers)

for (i in 1:pc) {
  
  per100.scaled[, ncol(per100.scaled) + 1] <- pca$x[, i]
  
}

pc.cols <- c()

for (i in 1:pc) {
  
  pc.cols <- c(pc.cols, paste('PC', i, sep = ''))
  
}

names(per100.scaled)[(ncol(per100.scaled) - pc + 1):ncol(per100.scaled)] <- pc.cols

ggplot(data = per100.scaled,
       aes(x = PC1,
           y = PC2)) +
  geom_point() +
  theme_solarized_2()

per100.scaled$cluster <- kmeans.all[[k]]$cluster

per100.scaled <- per100.scaled %>%
  left_join(PC.centers, by = 'cluster')

per100.scaled$center.dist <- sqrt((per100.scaled$centers.PC1 - per100.scaled$PC1) ^ 2
                                  + (per100.scaled$centers.PC2 - per100.scaled$PC2) ^ 2)

colors <- data.frame(cluster = seq(1, k),
                     color = c('#2aa198', '#839496', '#b58900', '#d33682',
                               '#6c71c4', '#268bd2', '#dc322f', '#859900',
                               '#073642', '#cb4b16'))

per100.scaled <-  per100.scaled %>%
  left_join(colors, by = 'cluster')

ggplot(data = per100.scaled,
       aes(x = PC1,
           y = PC2)) +
  geom_point(color = per100.scaled$color) +
  theme_solarized_2()

rm(list = c('i', 'pc.cols'))

# EVALUATION --------------------------------------------------------------

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled,
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = per100.scaled$color,
                     alpha = 0.15) +
          geom_point(data = per100.scaled[per100.scaled$cluster == i, ],
                     color = colors[i, 2]) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i)) +
          theme_solarized_2())
  
}

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled[per100.scaled$cluster == i, ],
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = colors[i, 2]) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i)) +
          theme_solarized_2())
  
}

## CLOSEST TO CENTER ------------------------------------------------------

closest.5 <- per100.scaled %>%
  arrange(center.dist) %>%
  group_by(cluster) %>%
  slice(1:5)

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled[per100.scaled$cluster == i, ],
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = colors[i, 2],
                     alpha = 0.1) +
          geom_point(data = closest.5[closest.5$cluster == i, ],
                     aes(color = Player),
                     size = 2) +
          geom_point(data = PC.centers[PC.centers$cluster == i, ],
                     aes(x = centers.PC1,
                         y = centers.PC2),
                     color = '#002b36',
                     shape = 15,
                     size = 3) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i),
                  subtitle = 'Closest to Cluster Center') +
          theme_solarized_2())
  
}

## MINUTES PLAYED ---------------------------------------------------------

mp.5 <- per100.scaled %>%
  arrange(desc(MP)) %>%
  group_by(cluster) %>%
  slice(1:5)

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled[per100.scaled$cluster == i, ],
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = colors[i, 2],
                     alpha = 0.1) +
          geom_point(data = mp.5[mp.5$cluster == i, ],
                     aes(color = Player),
                     size = 2) +
          geom_point(data = PC.centers[PC.centers$cluster == i, ],
                     aes(x = centers.PC1,
                         y = centers.PC2),
                     color = '#002b36',
                     shape = 15,
                     size = 3) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i),
                  subtitle = 'Most Minutes Played') +
          theme_solarized_2())
  
}

## SEASON COUNT -----------------------------------------------------------

count.5 <- per100.scaled %>%
  group_by(cluster, Player) %>%
  summarize(count = n()) %>%
  arrange(cluster, desc(count)) %>%
  slice(1:5)

count.5.per100.scaled <- per100.scaled%>%
  semi_join(count.5, by = c('Player', 'cluster')) %>%
  arrange(cluster)

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled[per100.scaled$cluster == i, ],
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = colors[i, 2],
                     alpha = 0.1) +
          geom_point(data = count.5.per100.scaled[count.5.per100.scaled$cluster == i, ],
                     aes(color = Player),
                     size = 2) +
          geom_point(data = PC.centers[PC.centers$cluster == i, ],
                     aes(x = centers.PC1,
                         y = centers.PC2),
                     color = '#002b36',
                     shape = 15,
                     size = 3) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i),
                  subtitle = 'Most Seasons') +
          theme_solarized_2())
  
}


#####

for (i in 1:k) {
  
  print(ggplot(data = per100.scaled[per100.scaled$cluster == i, ],
               aes(x = PC1,
                   y = PC2)) +
          geom_point(color = colors[i, 2]) +
          geom_point(data = mp.5[mp.5$cluster == i, ],
                     aes(x = PC1,
                         y = PC2),
                     color = 'black',
                     size = 2) +
          geom_label_repel(data = mp.5[mp.5$cluster == i, ],
                    aes(label = Player)) +
          xlab('PC1') +
          ylab('PC2') +
          ggtitle(paste('Cluster', i),
                  subtitle = 'Top Minutes Players Noted') +
          theme_solarized_2())
  
}






plots.dir.path <- list.files(tempdir(), pattern="rs-graphics", full.names = TRUE)
plots.png.paths <- list.files(plots.dir.path, pattern=".png", full.names = TRUE)
file.copy(from=plots.png.paths, to="Plots")
