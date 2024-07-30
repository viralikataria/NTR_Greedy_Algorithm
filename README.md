NTR Greedy Algorithm 

Instructions to run (Current code was written with the version1.1 files):
1. Make sure you have downloaded the necessary files from: https://osf.io/e95qw/?view_only=167fb28c4842491a885b91435c57b2f0
2. Run the Transcription_Converter.R file and then run the English Sublexical Toolkitv1.1.Rmd file. This ensures you have all the necessary function loaded into your current environment.
3. In the R environment make sure that the following files have been imported: wordfrequency, wordlist_v1_2, newTable
4. Run the All_Mappings_Wordlist.R file. This ensures thst all the functions from this file are now stored in your current environment
5. Steps 1-4 need to be run everytime you have a new environement in RStudio
6. Run the build_word_list function using the newTable file as the parameter. I reccommend storing the output into a variable, as this function returns multiple things.
7. You should see numbers being printed out in the console if all the above steps were done correctly
8. You can access the wordlist in the console by doing outputVariableYouChose$wordlist



Overview of the functions:
filter_word_length(word_to_check, min_length, max_length)
  This function checks if the word_to_check is between the min and max length(inclusive), returns true if it is, else false. You can update the min_length and max_length parameters as necessary.

filter_word_frequency(word, min_frequency)
  This function checks if the word in greater than the min_frequency, retunrs true if it is, flase if it is not. You can update the min_frequency parameter as necessary.

filter_word_by_syllable(word, min_syllable_num)
  

