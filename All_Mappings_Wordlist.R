library(dplyr)

# Filters out words in the list that are not within a minimum and maximum length (inclusive)
filter_word_length <- function(word_to_check, min_length, max_length) {
  word_length <- nchar(word_to_check)
  return(word_length >= min_length && word_length <= max_length)
}
#filters out words based on frequency
filter_word_frequency <- function (word, min_frequency){
  if(wordfrequency[wordfrequency$Word==word, ]$frequency[1] > min_frequency){      #filters words with a frequency 
    return(TRUE)
  }
  return(FALSE)
  
}
#filters out words based on syllable length
filter_word_by_syllable <- function( word, min_syllable_num){
  syllables <- wordlist_v1_2[wordlist_v1_2$spelling == word, ]$syllables[1]
  if (is.na(syllables)) {
    return(FALSE)
  }
  return(syllables > min_syllable_num)
    
}
# filters out specific words that we dont want in the list such as profanity
filter_specific_words <- function(word){
  words_to_filter <- list("motherfucker")
  for (i in words_to_filter){
    if (word == i){
      return(FALSE)
    }
  }
  return(TRUE)
}

#function to filter out any words that have duplicate spellings in the wordlist
#can also use the function to ensure we can get several unique lists of words
filter_out_duplicate_spellings <- function(wordlist, word){
  if(is.null(wordlist)){
    return(TRUE)
  }
  for(i in wordlist){
    if (word == i){
      return(FALSE)
    }
  }
  return(TRUE)
  
}



#Gives each word a point value based on how many unique mappings it contains. Adds additional points based on how
#rare its mappings are. 
get_word_points <- function(word_index, mappinglist, wordlist, previousWords){
  word <- wordlist_v1_1[[word_index,1]] 
  if(!filter_word_frequency(word, 3)){      #filters words with a frequency 
    return(0)
  }
  
  if(!filter_word_by_syllable(word, 2)){          #filters out word by number of syllables
    return(0)
  }
  
  if(!filter_specific_words(word)){
    return(0)
  }
  if(!filter_out_duplicate_spellings(wordlist, word)){ # filters out duplicate spellings
    return(0)
  }
  if(!filter_out_duplicate_spellings(previousWords, word)){ # filters out words that we have already used, to generate unique lists
    return(0)
  }
  
  points <- 0
  rarity <- 0
  for (i in seq_len(ncol(scored_words_PG[[word_index]]))){
    phoneme <- scored_words_PG[[word_index]][1,i]
    grapheme <- scored_words_PG[[word_index]][2,i]
    position <- scored_words_PG[[word_index]][3,i]
    row_number <- which(mappinglist$phoneme==inhouse_to_ipa(phoneme) &
                          mappinglist$grapheme==grapheme & mappinglist$position==position,)
    #print(paste("row number: ", row_number))
    
    if(length(row_number) != 0){
      points <- points + 100 
      rarity <- rarity + 5000/(mappinglist[[row_number, 5]])
    }
  }
  
  if(points >= 200 && rarity > 500){
    points <- points + 5000
  }
  
  if(points >= 200 && rarity > 750){    
    points <- points + 10000
  }
  
  if(points == 100){
    points <- 0
    rarity <- 1
  }
  return(points+rarity)
}

#Returns index of word that currently holds the highest number of points
highest_point <- function(mappinglist, wordlist, previousWords){
  final_val <- 0
  final_index <- 0
  for (i in 1:nrow(wordlist_v1_1)){
    cur_val <- get_word_points(i, mappinglist, wordlist, previousWords)  
    if(cur_val > final_val){
      final_val <- cur_val
      final_index <- i
    }
  }
  return(final_index)
}



#Returns the list of words using the auxillary methods defined
build_word_list <- function(mappinglist, previousWords){
  wordlist <- data.frame(words = character(), target = character(), non_target = character(), all_mappings = character(), stringsAsFactors = FALSE)
  word_info <- list()

  used_mappings <- list() # update this later
  
  
  #making sure the row exists in the list and that the lists of positions are not empty
  while(nrow(mappinglist) > 0 ){ # add: && !all(sapply(positional, function(df) nrow(df) == 0))
    print(nrow(mappinglist))
    curr_word <- highest_point(mappinglist, wordlist$spelling, previousWords)
    #print(curr_word)
    if (curr_word > 0){
      
      # get current word mappings
      word_mappings <- scored_words_PG[[curr_word]]
      
      #tuple formatting: [phoneme, grapheme, position]
       
      target_mappings <- list()
      non_target_mappings <- list()
      all_mappings <- list()
      
      # check that word mappings is a data frame with the correct columns
      if(is.matrix(word_mappings) || is.data.frame(word_mappings)){
        word_mappings <- as.data.frame(word_mappings)
        
      } else{
        stop("word_mappings is not a matrix or a data_frame")
      }
      #print(word_mappings)
      # flatten word_mappings in to a list
      for(col_index in seq_along(word_mappings)){
        column_data <- word_mappings[, col_index]
        
        phoneme <- column_data[1]
        grapheme <- column_data[2]
        position <- column_data[3]
        
        
        if (!is.na(phoneme) && !is.na(grapheme) && !is.na(position)){ # if of the values are null then them to word_info list
          # word_info <- append(word_info, list(data.frame(word = wordlist_v1_1[curr_word,1],phoneme = phoneme, grapheme = grapheme, position = position))) 
          tuple <- list(phoneme, grapheme, position)
          #adds the tuple to the list of all the mappings for the word
          all_mappings <- append(all_mappings, list(tuple))
          
          if (!tuple_exists(used_mappings, tuple)){
            # if the pg-position pair is not already in the list of used mappings then we add it to target and used_mapping list
            target_mappings <- append(target_mappings, list(tuple))
            used_mappings <- append(used_mappings, list(tuple))
          }
          else{
            # we add it to the non target list since it is not a target mapping
            non_target_mappings <- append(non_target_mappings, list(tuple))
          }
        }
        
        
      }
      #converting the all mappings, target and non target lists to strings 
      target_string <- convert_list_to_string(target_mappings)
      non_target_string <- convert_list_to_string(non_target_mappings)
      all_mappings_string <- convert_list_to_string(all_mappings)
      #print(target_string)
      #print(" ")
      #print(non_target_string)
      
      # add current word to the word list, along with its targetmappings,  non target mappings, and all the mapppings in the word
      wordlist <- rbind(wordlist, data.frame(words = wordlist_v1_1[curr_word,1],target = target_string, non_target = non_target_string, all_mappings = all_mappings_string, stringsAsFactors = FALSE ))
      #print(wordlist)
      
      # update mapping list by removing the word that was just used
      mappinglist <- new_mapping_list(word_mappings, mappinglist)
      
    }
    else{
      return(list(wordlist = wordlist, word_info = word_info, used_mappings = used_mappings)) # used mappings is unused rn, might not need
    }
    
  }

  return(list(wordlist = wordlist,word_info = word_info, used_mappings = used_mappings))
}

#Removes the mappings from the last chosen word and creates a new list of mappings without them
new_mapping_list <- function(word, mappinglist){
  for (i in 1:length(word)){
    if (nrow(filter(mappinglist, phoneme == inhouse_to_ipa(word[1,i]), grapheme == word[2, i]) != 0)){
      mappinglist <- mappinglist[!(mappinglist$phoneme == inhouse_to_ipa(word[1,i]) &
                 mappinglist$grapheme == word[2,i]), ]
    }
  }
  return(mappinglist)
}

#checks if all the mappings are being used
# need to update this to handle positional information
verify_mappings <- function(mapinglist, used_mappings){
  # Define the original mappings
  # original_mappings <- data.frame(
  #   phomene = c("aɪ", "aʊ", "eɪ", "oʊ", "ɔɪ", "ɛɹ", "ɪɹ", "ʊɹ", "tʃ", "θ", "ð", "dʒ", "i", "ɚ", "ɑ", "ɔ", "u", "ʊ", "ɪ", "æ", "ɛ", "ə", "ʌ", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "ŋ", "p", "ɹ", "s", "ʃ", "t", "v", "w", "z", "ʒ"),
  #   grapheme = c("5", "O", "8", "o", "2", "Er", "1r", "Ur", "C", "T", "D", "G", "i", "3", "a", "c", "u", "U", "1", "@", "E", "e", "^", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "N", "p", "r", "s", "S", "t", "v", "w", "z", "Z"),
  #   stringsAsFactors = FALSE
  # )
  
  
  
  # convert the original mappings to a set of strings
  original_mapping_strings <- apply(original_mappings, 1, function(row) paste(row["phoneme"], row["grapheme"], sep = "-"))
  print("Original mappings strings:")
  print(original_mapping_strings)
  
  # convert used_mappings into a unique set
  used_mappings_unique <- unique(used_mappings$pronunciation)
  
  print("Used mappings unique:")
  print(used_mappings_unique)
  
  # checks if all the original mappings are present in used mappings
  missing_mappings <- setdiff(original_mapping_strings, used_mappings_unique)

  
  if(length(missing_mappings) > 0){
    print("The following mappings are missing: ")
    print(missing_mappings)
    return(FALSE)
  }else{
    print("All mappings are present")
    return(TRUE)
  }
  
  
  
}


#standardizes all the tuples to ensure correct checking
standardize_tuple <- function(tuple) {
  return(sapply(tuple, as.character))
}

# Function to check if a tuple exists in the set
tuple_exists <- function(set_of_tuples, target_tuple) {
  target_tuple <- standardize_tuple(target_tuple)
  for (tuple in set_of_tuples) {
    if (all(standardize_tuple(tuple) == target_tuple)) {
      return(TRUE)
    }
  }
  return(FALSE)
}

# Function to add a tuple to the set if it doesn't already exist
add_tuple <- function(set_of_tuples, new_tuple) {
  if (!tuple_exists(set_of_tuples, new_tuple)) {
    set_of_tuples <- append(set_of_tuples, list(new_tuple))
  }
  return(set_of_tuples)
}

convert_list_to_string <- function(list_of_tuples) {
  return(paste(sapply(list_of_tuples, function(x) paste0("(", paste(x, collapse = ","), ")")), collapse = ";"))
}


  



