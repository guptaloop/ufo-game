require 'set'
require_relative 'dictionary'
require_relative 'assets/ufo'

class Game

	attr_accessor :alphabet, :correct_guesses, :incorrect_guesses, 
		:dictionary, :guess, :input_error

	def initialize
		## use Sets to optimize lookup and deletion operations
		@alphabet = Set.new | ("A".."Z")
		@correct_guesses = Set.new
		@incorrect_guesses = Set.new
		@dictionary = Dictionary.new
		@guess = ""
		@input_error = ""
	end

	def play
		until @dictionary.codeword_solved? || is_person_abducted?
			display_title_instrux if @guess == ""

			display_ufo
			display_incorrect_guesses
			@dictionary.display_codeword_hash
			@dictionary.display_matches
			prompt_player

			# # player will be caught in a loop until they enter a valid guess
			while is_guess_invalid?
				display_input_error
				prompt_player
			end

			is_guess_correct?
		end

		display_game_over_msg
		play_again?
	end

	def is_person_abducted?
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

	def display_incorrect_guesses
		incorrect_str = ""
		@incorrect_guesses.each { |letter| incorrect_str += letter + " "}
		puts "Incorrect Guesses: "
		incorrect_str == "" ? (puts "None") : (puts "#{incorrect_str}")
		puts
	end

	def prompt_player
		print "Please enter your guess: "
		@guess = gets.chomp.upcase
	end

	def is_guess_invalid?
		if @correct_guesses.include?(@guess) || @incorrect_guesses.include?(@guess)
			@input_error = "You can only guess that letter once, please try again."
			return true
		elsif !@alphabet.include?(@guess) || @guess.length != 1
			@input_error = "I cannot understand your input. Please guess a single letter."
			return true
		end
		return false
	end

	def display_input_error
		puts
		puts @input_error
		puts
	end

	def is_guess_correct?
		
		if @dictionary.get_codeword.include?(@guess)
			@correct_guesses.add(@guess)
			@dictionary.update_codeword_hash(@guess)
			@dictionary.update_matches("correct", @correct_guesses)
			unless @dictionary.codeword_solved?
				puts
				puts "Correct! You're closer to cracking the codeword."
			end
		else
			@incorrect_guesses.add(@guess)
			@dictionary.update_matches("incorrect", @incorrect_guesses)
			unless is_person_abducted?
				puts
				puts "Incorrect! The tractor beam pulls the person in further."
			end
		end
	end

	def display_game_over_msg
		if is_person_abducted?
			puts
			puts "Incorrect! The person has been abducted!"
		elsif @dictionary.codeword_solved?
			puts
			puts "Correct! You saved the person and earned a medal of honor!"
		end
		puts "The codeword is: #{@dictionary.get_codeword}."
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
# class end
end

if $PROGRAM_NAME == __FILE__
	Game.new.play
end