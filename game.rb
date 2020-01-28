require 'set'
require_relative 'assets/ufo'

class Game
  attr_reader :codeword, :alphabet, :guessed, :incorrect_guesses, 
    :incorrect_guess_count, :curr_guess, :char_indices, :codeword_hash

  def initialize
    @codeword = gen_codeword()
    # use Sets for faster lookup
    @alphabet = Set.new | ("A".."Z")
    @guessed = Set.new
    @incorrect_guesses = []
    @incorrect_guess_count = 0
    @curr_guess = ""
    @char_indices = create_char_indices()
    @codeword_hash = codeword_key()
    @error_msg = ""
  end

  def gen_codeword
    # convert nouns.txt to an array of strings
    words = []
    File.readlines("assets/nouns.txt").map do |word|
      word.delete!("\n")
      words << word.upcase
    end
    # randomly choose the codeword from the words array
    return words.sample
  end

  def codeword_key
    (@codeword.length).times.map { "_" }
  end

  def create_char_indices
    obj = {}
    
    @codeword.each_char.with_index do |char, idx|
      if obj[char]
        obj[char] << idx
      else
        obj[char] = [idx]
      end
    end

    return obj
  end

  def update_codeword_hash
    idxs = @char_indices[@curr_guess]
    idxs.each { |idx| @codeword_hash[idx] = @curr_guess }
  end

  def is_guess_correct?
    @guessed.add(@curr_guess)
    if @codeword.include?(@curr_guess)
      update_codeword_hash()
      return true
    else
      @incorrect_guess_count += 1
      @incorrect_guesses << @curr_guess
      return false
    end
  end

  def guess_is_invalid?()
    if @guessed.include?(@curr_guess)
      @error_msg = "You can only guess that letter once, please try again."
      return true
    elsif !@alphabet.include?(@curr_guess) || @curr_guess.length != 1
      @error_msg = "I cannot understand your input. Please guess a single letter."
      return true
    else
      return false
    end
  end

  def display_title_instrux
    puts "UFO: The Game"
    puts "Instructions: save us from alien abduction by guessing letters in the codeword."
  end

  def display_ufo
    puts UFO::DISPLAY[@incorrect_guess_count]
  end

  def display_incorrect_guesses()
    puts "Incorrect Guesses: "
    puts @incorrect_guesses.join(" ")
    puts
  end

  def display_codeword_hash
    puts "Codeword:"
    puts @codeword_hash.join(" ")
  end

  def prompt_user
    puts "Please enter your guess: "
    @curr_guess = gets.chomp.upcase
  end

  def render
    while (@incorrect_guess_count < 6 && @codeword_hash.include?("_"))
      display_title_instrux() if @curr_guess == ""
    
      display_ufo()
      display_incorrect_guesses()
      display_codeword_hash()
      puts @codeword

      prompt_user()
      # user will be caught in a loop until they enter a valid guess
      while guess_is_invalid?()
        puts @error_msg
        prompt_user()
      end

      # check if guess is correct, display appropriate msg
      if is_guess_correct?()
        puts "Correct! You're closer to cracking the codeword."
      else
        puts "Incorrect! The tractor beam pulls the person in further."
      end

    end

    
    display_ufo()
    puts "GAME OVER!"
    # play again? 

  end
  
end


# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.render
end