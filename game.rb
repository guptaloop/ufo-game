require 'set'
require_relative 'assets/ufo'

class Game
	attr_reader :alphabet, :correct_guesses, :incorrect_guesses, :dictionary_matches, 
		:codeword, :codeword_char_idxs, :codeword_hash, :curr_guess, :input_error

	def initialize
		## use Sets to optimize lookup and deletion operations
		@alphabet = Set.new | ("A".."Z")
		@correct_guesses = Set.new
		@incorrect_guesses = Set.new
		@dictionary_matches = Set.new
		@codeword = select_codeword()
		@codeword_char_idxs = create_codeword_char_idxs()
		@codeword_hash = create_codeword_hash()
		@curr_guess = ""
		@input_error = ""
	end

	## CODEWORD METHODS ##
	def select_codeword
		words = File.readlines("assets/nouns.txt").map { |word| word.upcase }
		@dictionary_matches = words.to_set
		return words.sample.delete("\n")
	end

	def create_codeword_char_idxs
		obj = {}
		@codeword.each_char.with_index do |char, idx|
			obj[char] ? obj[char] << idx : obj[char] = [idx]
		end

		return obj
	end

	def create_codeword_hash
		(@codeword.length).times.map { "_" }
	end
	####

	def codeword_has_been_guessed?
		!@codeword_hash.include?("_") ? true : false
	end

	def person_has_been_abducted?
		@incorrect_guesses.size >= 6 ? true : false
	end

	def display_title_instrux
		puts
		puts "UFO: The Game"
		puts "Instructions: save us from alien abduction by guessing letters in the codeword."
	end

	def display_ufo
		puts
		puts UFO::DISPLAY[@incorrect_guesses.size]
		puts
	end

	def display_incorrect_guesses()
		incorrect_str = ""
		@incorrect_guesses.each { |letter| incorrect_str += letter + " "}
		puts "Incorrect Guesses: "
		incorrect_str == "" ? (puts "None") : (puts "#{incorrect_str}")
		puts
	end

	def display_codeword_hash
		puts "Codeword: "
		puts @codeword_hash.join(" ")
		puts
	end

	def prompt_player_for_guess
		print "Please enter your guess: "
		@curr_guess = gets.chomp.upcase
	end

	def guess_is_invalid?()
		if @correct_guesses.include?(@curr_guess) || @incorrect_guesses.include?(@curr_guess)
			@input_error = "You can only guess that letter once, please try again."
			return true
		elsif !@alphabet.include?(@curr_guess) || @curr_guess.length != 1
			@input_error = "I cannot understand your input. Please guess a single letter."
			return true
		else
			return false
		end
	end

	def display_input_error
		puts
		puts @input_error
		puts
	end

	## BONUS - dictionary matches algorithm
	def update_dictionary_matches(guess)
		if (guess == "correct")
			@dictionary_matches.each do |word|
				@correct_guesses.each do |letter|
					if word.include?(letter)
						idxs = @codeword_char_idxs[letter]
						# delete any words from @dictionary_matches that don't have a 
						# correct guess at the correct idx(s)
						idxs.each do |idx|
							@dictionary_matches.delete(word) unless word[idx] == letter
						end
					else
						# delete any words from @dictionary_matches that DO NOT contain
						# a correct guess
						@dictionary_matches.delete(word)
					end
				end
			end
		elsif (guess == "incorrect")
			# delete any words from @dictionary matches that contain an incorrect guess
			@incorrect_guesses.each do |letter|
				@dictionary_matches.each do |word|
					@dictionary_matches.delete(word) if word.include?(letter)
				end
			end
		end
		# remaining words in @dictionary_matches are possible matches based on all 
		# guesses made by the player
	end

	def is_guess_correct?
		if @codeword.include?(@curr_guess)
			@correct_guesses.add(@curr_guess)
			update_codeword_hash()
			update_dictionary_matches("correct")
			unless codeword_has_been_guessed?()
				puts
				puts "Correct! You're closer to cracking the codeword."
			end
		else
			@incorrect_guesses.add(@curr_guess)
			update_dictionary_matches("incorrect")
			unless person_has_been_abducted?()
				puts
				puts "Incorrect! The tractor beam pulls the person in further."
			end
		end
	end

	def update_codeword_hash
		idxs = @codeword_char_idxs[@curr_guess]
		idxs.each { |idx| @codeword_hash[idx] = @curr_guess }
	end

	def display_dictionary_matches
		puts "Number of dictionary matches: #{@dictionary_matches.size}"
		puts
	end

	def display_game_over_msg
		if person_has_been_abducted?()
			puts
			puts "Incorrect! The person has been abducted!"
		elsif codeword_has_been_guessed?()
			puts
			puts "Correct! You saved the person and earned a medal of honor!"
		end
		puts "The codeword is: #@codeword."
		puts
	end

	def play_again?
		print "Would you like to play again (Y/N)? "
		gets.chomp.upcase == 'Y' ? Game.new.play : (
			puts
			puts "Goodbye!"
			puts
		)
	end

	def play
		until codeword_has_been_guessed?() || person_has_been_abducted?()
			display_title_instrux() if @curr_guess == ""

			display_ufo()
			display_incorrect_guesses()
			display_codeword_hash()
			display_dictionary_matches()
			prompt_player_for_guess()

			# player will be caught in a loop until they enter a valid guess
			while guess_is_invalid?()
				display_input_error()
				prompt_player_for_guess()
			end

			is_guess_correct?()
		end

		display_game_over_msg()
		play_again?()
	end

end

if $PROGRAM_NAME == __FILE__
	Game.new.play
end