# Goals -----------------------------------------------------
# Algorithm will take 3 arguments
# 1. Corpus - Which is this case the tweets
# 2. Segmentation - Which in this case is the date
# 3. The number of topics - In this case, let's make 3 topics per day


library(tidyverse)
library(tidytext)
library(tm)
library(stringr)
library(SnowballC)


# Get data and transform ------------------------------------
# Remove all objects from enviroment
rm(list = ls())


# Load posts and events
posts_tbl <- readRDS(file = "20170302_TopicsFromTwitter/data/posts.Rds")


# Only keep popular tweets
posts_tbl <- filter(posts_tbl, nb_actions >= 1)



# Only keep relevant protest movement -----------------------
# Group events by date, actors and country code and only keep significant events per day
movements_tbl <- events_tbl %>%
  filter(actor1_code == "OPP") %>%
  filter(!is.na(actor1_code)) %>%
  filter(!is.na(actor2_code)) %>%
  group_by(published_date, actor1_name, actor2_name, action_geo_country_code) %>%
  summarise(n_events = n(), total_sources = sum(num_sources), total_articles = sum(num_articles)) %>%
  filter(total_articles >= 25) %>%
  arrange(published_date, desc(total_articles))

# Left join meta titles and descriptions
movements_texts_tbl <- movements_tbl %>%
  left_join(events_tbl, by = c("published_date", "actor1_name", "actor2_name", 
                               "action_geo_country_code")) %>%
  select(published_date, actor1_name, actor2_name, action_geo_country_code, n_events, 
         total_sources, total_articles, url, title, description)



# Find most frequent movement terms -------------------------
# Create empty data frame to hold frequent terms per movement
movement_freq_terms_tbl <- tibble(
  published_date = as.Date(character()),
  actor1_name = character(),
  actor2_name = character(),
  action_geo_country_code = character(),
  freq_terms = list()
)

# Group event's meta info into a corpus for each movement and extract associated frequent terms
for (i in 1:nrow(movements_tbl)){
  # Subset movement_texts_tbl
  movements_texts_sub_tbl <- movements_texts_tbl %>%
    filter(published_date == movements_tbl[i, ]$'published_date') %>%
    filter(actor1_name == movements_tbl[i, ]$'actor1_name') %>%
    filter(actor2_name == movements_tbl[i, ]$'actor2_name') %>%
    filter(action_geo_country_code == movements_tbl[i, ]$'action_geo_country_code')
  
  
  # Create corpus
  titles <- str_replace_all(movements_texts_sub_tbl$title, "[[:punct:]]", " ")
  titles <- titles[!is.na(titles)]
  
  descriptions <- str_replace_all(movements_texts_sub_tbl$description, "[[:punct:]]", " ")
  descriptions <- descriptions[!is.na(descriptions)]
  
  documents <- c(titles, descriptions)
  rm(titles, descriptions)
  
  movement_corpus <- Corpus(VectorSource(documents))
  movement_corpus <- tm_map(movement_corpus, content_transformer(tolower))
  rm(documents)
  
  
  # Remove stop words and protest word from corpus
  movement_corpus <- tm_map(movement_corpus, removePunctuation) 
  movement_corpus <- tm_map(movement_corpus, removeNumbers)
  removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
  movement_corpus <- tm_map(movement_corpus, content_transformer(removeURL))
  my_stopwords <- c(stopwords("english"), "protest", "protests", "protesters")
  movement_corpus <- tm_map(movement_corpus, removeWords, my_stopwords)
  
  rm(removeURL, my_stopwords)
  
  
  ## Stem words from titles corpus
  movement_corpus <- tm_map(movement_corpus, stemDocument)
  
  
  # Convert titles corpus to Term Document Matrices
  movement_tdm <- TermDocumentMatrix(movement_corpus, 
                                   control = list(removePunctuation = TRUE, 
                                                  stopwords =  TRUE, 
                                                  removeNumbers = TRUE, tolower = TRUE)) 
  movement_freq_terms_vector <- findFreqTerms(movement_tdm, 5)
  
  
  # Save frequent terms as a character vector in movement_freq_terms dataframe
  if (length(movement_freq_terms_vector) > 0){
    tmp_movement_freq_terms_tbl <- tibble(published_date = movements_tbl[i, ]$'published_date', 
                                          actor1_name = movements_tbl[i, ]$'actor1_name', 
                                          actor2_name = movements_tbl[i, ]$'actor2_name', 
                                          action_geo_country_code = movements_tbl[i, ]$'action_geo_country_code', 
                                          freq_term = movement_freq_terms_vector)
    
    movement_freq_terms_tbl <- rbind(movement_freq_terms_tbl, tmp_movement_freq_terms_tbl)
  }
}


# Cleanup
rm(movements_texts_sub_tbl, tmp_movement_freq_terms_tbl)
rm(i, movement_corpus, movement_tdm, movement_freq_terms_vector)



# Remove terms that are in more than 3% of documents -------
# Extract keywords that are in many documents (inspired by Inverse Document Frequency method)
spread_terms <- movement_freq_terms_tbl %>%
  group_by(freq_term) %>%
  summarize(count = n()) %>%
  mutate(spread = count / nrow(movements_tbl)) %>%
  filter(spread >= 0.03) %>%
  arrange(desc(spread), desc(count))


# Remove too widely spread keywords from movement's top keywords
movement_clean_freq_terms_tbl <- movement_freq_terms_tbl %>%
  left_join(spread_terms, by = 'freq_term') %>%
  filter(is.na(count))


# Cleanup
rm(events_tbl, spread_terms)
rm(movement_freq_terms_tbl, movements_texts_tbl)
  



# Associate each tweet to most appropriate movement ---------
# Expand list of keywords
posts_expanded_tbl <- posts_tbl %>%
  unnest_tokens(keyword, text)


# Stem keywords, remove stop words, urls and other cleaning up tasks
stopWords <- stopwords("en")

posts_expanded_tbl <- posts_expanded_tbl %>%
  mutate(keyword_stem = wordStem(keyword)) %>%
  filter(!(keyword %in% stopWords)) %>%
  filter(!grepl('http.* *', keyword)) %>%
  filter(!grepl('protest', keyword))


# Go through daily events and tweets, and score associations
for (i in 1:length(levels(as.factor(movements_tbl$published_date)))){
  # Keep daily posts and events
  daily_posts <- posts_tbl %>%
    filter(date == levels(as.factor(movements_tbl$published_date))[i])
  
  daily_movements <- movements_tbl %>%
    filter(published_date == levels(as.factor(movements_tbl$published_date))[i])
  
  
  # Create a full data frame that contains all possiblities between posts and movements
  
}

# Calculate number of occurences of each movement's relevant terms per tweet 

# See if there is a clear winner (at least X number of relevant terms) + 
# important difference with other movements - or ignore tweet

# Assign tweet to movement which has the most relevant terms
# Create empty data frame to hold frequent terms per movement


