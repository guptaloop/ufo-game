require 'set'
require_relative 'dictionary'
require_relative 'assets/ufo'
require 'byebug'

class Game

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
		until @dictionary.is_codeword_solved? || is_person_abducted?
			render_title_instrux if @guess == ""
			render_ufo
			render_incorrect_guesses
			@dictionary.render_codeword_hash
			@dictionary.render_codeword_matches
			prompt_player
			# player will be caught in a loop until they enter a valid guess
			while is_guess_invalid?
				render_input_error
				prompt_player
			end
			is_guess_correct?
		end

		render_game_over_msg
		render_play_again_prompt?
	end

	# no need to expose these methods outside of this class
	private

	def is_person_abducted?
		@incorrect_guesses.size >= 6 ? true : false
	end

	def render_title_instrux
		puts
		puts "UFO: The Game"
		puts "Instructions: save us from alien abduction by guessing letters in the codeword."
	end

	def render_ufo
		puts
		puts UFO::RENDER[@incorrect_guesses.size]
		puts
	end

	def render_incorrect_guesses
		str = ""
		@incorrect_guesses.each { |letter| str += letter + " "}
		puts "Incorrect Guesses: "
		str == "" ? (puts "None") : (puts "#{str}")
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

	def render_input_error
		puts
		puts @input_error
		puts
	end

	def is_guess_correct?
		if @dictionary.codeword.include?(@guess)
			@correct_guesses.add(@guess)
			@dictionary.update_codeword_hash(@guess)
			@dictionary.update_codeword_matches("correct", @correct_guesses)
			unless @dictionary.is_codeword_solved?
				puts
				puts "Correct! You're closer to cracking the codeword."
			end
		else
			@incorrect_guesses.add(@guess)
			@dictionary.update_codeword_matches("incorrect", @incorrect_guesses)
			unless is_person_abducted?
				puts
				puts "Incorrect! The tractor beam pulls the person in further."
			end
		end
	end

	def render_game_over_msg
		if is_person_abducted?
			puts
			puts "Incorrect! The person has been abducted!"
		elsif @dictionary.is_codeword_solved?
			puts
			puts "Correct! You saved the person and earned a medal of honor!"
		end
		puts "The codeword is: #{@dictionary.codeword}."
		puts
	end

	def render_play_again_prompt?
		print "Would you like to play again (Y/N)? "
		gets.chomp.upcase == 'Y' ? Game.new.play : (
			puts
			puts "Goodbye!"
			puts
		)
	end

end # class end

if $PROGRAM_NAME == __FILE__
	Game.new.play
end