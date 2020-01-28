require 'set'
require_relative 'assets/ufo'

class Game
  attr_reader :codeword, :codeword_char_idxs, :codeword_hash, :alphabet,
    :curr_guess, :guessed, :incorrect_guesses, :input_error 

  def initialize
    @codeword = select_codeword()
    @codeword_char_idxs = create_codeword_char_idxs()
    @codeword_hash = create_codeword_hash()
    @alphabet = Set.new | ("A".."Z")
    @curr_guess = ""
    @guessed = Set.new
    @incorrect_guesses = []
    @input_error = ""
  end

  ## CODEWORD METHODS ##
  def select_codeword
    # convert nouns.txt to an array of strings
    words = []
    File.readlines("assets/nouns.txt").map do |word|
      word.delete!("\n")
      words << word.upcase
    end
    # randomly choose the codeword from the words array
    return words.sample
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

  def display_title_instrux
    puts
    puts "UFO: The Game"
    puts
    puts "Instructions: save us from alien abduction by guessing letters in the codeword."
  end

  def display_ufo
    puts UFO::DISPLAY[@incorrect_guesses.length]
    puts
  end

  def display_incorrect_guesses()
    puts "Incorrect Guesses: "
    puts @incorrect_guesses.join(" ")
    puts
  end

  def display_codeword_hash
    puts "Codeword: "
    puts @codeword_hash.join(" ")
    puts
  end
  
  def update_codeword_hash
    idxs = @codeword_char_idxs[@curr_guess]
    idxs.each { |idx| @codeword_hash[idx] = @curr_guess }
  end

  def prompt_user
    puts "Please enter your guess: "
    @curr_guess = gets.chomp.upcase
  end

  def display_input_error
    puts
    puts @input_error
    puts
  end

  def guess_is_invalid?()
    if @guessed.include?(@curr_guess)
      @input_error = "You can only guess that letter once, please try again."
      return true
    elsif !@alphabet.include?(@curr_guess) || @curr_guess.length != 1
      @input_error = "I cannot understand your input. Please guess a single letter."
      return true
    else
      return false
    end
  end

  def is_guess_correct?
    @guessed.add(@curr_guess)
    
    if @codeword.include?(@curr_guess)
      update_codeword_hash()
      puts
      puts "Correct! You're closer to cracking the codeword."
    else
      @incorrect_guesses << @curr_guess
      puts
      puts "Incorrect! The tractor beam pulls the person in further."
    end
  end

  def play
    while (@incorrect_guesses.length < 6 && @codeword_hash.include?("_"))
      display_title_instrux() if @curr_guess == ""
    
      display_ufo()
      display_incorrect_guesses()
      display_codeword_hash()
      
      puts @codeword #remove this line

      prompt_user()
      # user will be caught in a loop until they enter a valid guess
      while guess_is_invalid?()
        display_input_error()
        prompt_user()
      end

      # check if guess is correct, display appropriate msg
      is_guess_correct?()

    end

    
    display_ufo()
    puts "GAME OVER!"
    # play again? 

  end
  
end

# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.play
end