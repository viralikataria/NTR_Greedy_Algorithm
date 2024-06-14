library(dplyr)

# Filters out words in the list that are not within a minimum and maximum length (inclusive)
filter_word_length <- function(word_to_check, min_length, max_length) {
  word_length <- nchar(word_to_check)
  return(word_length >= min_length && word_length <= max_length)
}

filter_word_frequency <- function (word, min_frequency){
  if(wordfrequency[wordfrequency$Word==word, ]$frequency[1] > min_frequency){      #filters words with a frequency 
    return(TRUE)
  }
  return(FALSE)
  
}
filter_word_by_syllable <- function( word, min_syllable_num){
  syllables <- wordlist_v1_2[wordlist_v1_2$spelling == word, ]$syllables[1]
  if (is.na(syllables)) {
    return(FALSE)
  }
  return(syllables > min_syllable_num)
    
}

#Gives each word a point value based on how many unique mappings it contains. Adds additional points based on how
#rare its mappings are. 
get_word_points <- function(word_index, mappinglist){
  word <- wordlist_v1_1[[word_index,1]] 
  if(!filter_word_frequency(word, 2)){      #filters words with a frequency 
    return(0)
  }
  
  if(!filter_word_by_syllable(word, 2)){          #filters out word by number of syllables
    return(0)
  }
  
  points <- 0
  rarity <- 0
  for (i in seq_len(ncol(scored_words_PG[[word_index]]))){
    phoneme <- scored_words_PG[[word_index]][1,i]
    grapheme <- scored_words_PG[[word_index]][2,i]
    row_number <- which(mappinglist$phoneme==inhouse_to_ipa(phoneme) &
                          mappinglist$grapheme==grapheme,)
    
    if(length(row_number) != 0){
      points <- points + 100 
      rarity <- rarity + 5000/(mappinglist[[row_number, 3]])
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
highest_point <- function(mappinglist){
  final_val <- 0
  final_index <- 0
  for (i in 1:nrow(wordlist_v1_1)){
    cur_val <- get_word_points(i, mappinglist)  
    if(cur_val > final_val){
      final_val <- cur_val
      final_index <- i
    }
  }
  return(final_index)
}



#Returns the list of words using the auxillary methods defined
build_word_list <- function(mappinglist){
  wordlist <- data.frame(words = c())
  used_mappings <- data.frame(phoneme = character(), grapheme = character(), stringsAsFactors = FALSE)
  
  while(nrow(mappinglist) > 0){
    print(nrow(mappinglist))
    curr_word <- highest_point(mappinglist)
    if (curr_word > 0){
      # add current word to the word list
      wordlist <- rbind(wordlist, data.frame(words =wordlist_v1_1[curr_word,1], stringsAsFactors = FALSE ))
      
      # get current word mappings
      word_mappings <- scored_words_PG[[curr_word]]
      
      
      # check that word mappings is a data frame with the correct columns
      if(is.matrix(word_mappings) || is.data.frame(word_mappings)){
        word_mappings <- as.data.frame(word_mappings)
        colnames(word_mappings) <- c("phoneme", "grapheme")
      } else{
        stop("word_mappings is not a matrix or a data_frame")
      }
      
      
      # flatten used_mappings in to a list
      for(i in 1:nrow(word_mappings)){
        used_mappings <- append(used_mappings, paste(word_mappings[i, "phoneme"], word_mappings[i,"grapheme"], sep= "-"))
      }
      
      
      # update mapping list
      mappinglist <- new_mapping_list(word_mappings, mappinglist)
      
    }
    else{
      return(list(wordlist = wordlist, used_mappings = used_mappings))
    }
  }
  
  return(list(wordlist = wordlist, used_mappings = used_mappings))
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
verify_mappings <- function(used_mappings){
  # Define the original mappings
  original_mappings <- data.frame(
    phomene = c("aɪ", "aʊ", "eɪ", "oʊ", "ɔɪ", "ɛɹ", "ɪɹ", "ʊɹ", "tʃ", "θ", "ð", "dʒ", "i", "ɚ", "ɑ", "ɔ", "u", "ʊ", "ɪ", "æ", "ɛ", "ə", "ʌ", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "ŋ", "p", "ɹ", "s", "ʃ", "t", "v", "w", "z", "ʒ"),
    grapheme = c("5", "O", "8", "o", "2", "Er", "1r", "Ur", "C", "T", "D", "G", "i", "3", "a", "c", "u", "U", "1", "@", "E", "e", "^", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "N", "p", "r", "s", "S", "t", "v", "w", "z", "Z"),
    stringsAsFactors = FALSE
  )
  # convert the original mappings to a set of strings
  original_mapping_strings <- apply(original_mappings, 1, function(row) paste(row["phoneme"], row["grapheme"], sep = "-"))
  print("Original mappings:")
  print(original_mapping_strings)
  
  # convert used_mappings into a unique set
  used_mappings_unique <- unique(used_mappings)
  
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


  



