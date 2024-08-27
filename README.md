NTR Greedy Algorithm 

If you have questions please ocntact me at vkataria@terpmail.umd.edu

Instructions to run (Current code was written with the version1.2 files):
1. Make sure you have downloaded the necessary files from: https://osf.io/e95qw/?view_only=167fb28c4842491a885b91435c57b2f0
2. Run the Transcription_Converter.R file and then load the Toolkit_v1.2 R workspace onto your R session. This ensures you have all the necessary functions of the toolkit loaded into your current environment.
3. In the R environment make sure that the following files have been imported: wordfrequency, wordlist_v1_2 (even though it runs on version1.2 currently, this list has the syllables also included), newTable
4. Run the All_Mappings_Wordlist.R file. This ensures thst all the functions from this file are now stored in your current environment
5. Steps 1-4 need to be run everytime you have a new environement in RStudio
6. Run the build_word_list function using the newTable file as the mapping_list parameter, NULL for the second paramteter for now. I reccommend storing the output into a variable, as this function returns multiple things.
7. You should see numbers being printed out in the console if all the above steps were done correctly
8. You can access the wordlist in the console by doing outputVariableYouChose$wordlist

Lists:
words_to_filter: This is a list that contains specific words we wish to filter out.

Overview of the functions:

filter_word_length(word_to_check, min_length, max_length)
  This function checks if the word_to_check is between the min and max length(inclusive), returns true if it is, else false. You can update the min_length and max_length parameters as necessary.

filter_word_frequency(word, min_frequency)
  This function checks if the word in greater than the min_frequency, retunrs true if it is, flase if it is not. You can update the min_frequency parameter as necessary.

filter_word_by_syllable(word, min_syllable_num)
  This function uses the wordlist_v1_2 file's syllable column to determine if the syllable number is greater than the min_syllable_num. Its returns true if it is else false.

filter_out_duplicate_spellings(wordlist, word)
  This funtion checks if the words exists in the wordlist. If it does then it returns false else true. (idk why i did it backwards but we ball)

get_word_points(word_index, mappingslist, wordlist, previousWords):
  This function assigns a word points given certain conditions. The word_index refers to the index of the word in the mappinglist, the mappinglist is the mappinglist, wordlist is a list of words that are already in the current list - it helps prevent duplicate spellings of words incase the phoneme and graphemes are differnt, and previousWords is a list that was already creted - this allows us to create multiple unique lists. This function will return 0 if the word matches a condition that needs to be filtered out, or the number of points + the rarity.

highest_point(mappinglist, wordlist, previousWords):
  This function uses an greedy algorithm to find the word with the most number of points at that given time. it return the final index. The parametrs are used to call the get_word_points function.

build_word_list(mappinglist, perviousWords):
  



  

