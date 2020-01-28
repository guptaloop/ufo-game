require 'set'
require_relative 'assets/ufo'

class Game
  attr_reader :codeword, :alphabet, :guessed, :incorrect_guesses, :curr_guess, :char_indices, :codeword_display

  def initialize
    @codeword = gen_codeword()
    # use Sets for faster lookup
    @alphabet = Set.new | ("a".."z")
    @guessed = Set.new
    @incorrect_guesses = 0
    @curr_guess = ""
    @char_indices = create_char_indices()
    @codeword_display = codeword_key()
  end

  def gen_codeword
    # convert nouns.txt to an array of strings
    words = []
    File.readlines("assets/nouns.txt").map do |word|
      word.delete!("\n")
      words << word
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

  def is_guess_correct?
    if @codeword.include?(@curr_guess) && !@guessed.include?(@curr_guess)
      return true
    else
      return false
    end
  end

  def render
    while (@incorrect_guesses <= 5 && @codeword_display.include?("_"))
      if @curr_guess == ""
        puts "UFO: The Game"
        puts "Instructions: save us from alien abduction by guessing letters in the codeword."
      elsif is_guess_correct?()
        puts "Correct! You're closer to cracking the codeword."
      else
        puts @incorrect_guesses
        puts "Incorrect! The tractor beam pulls the person in further."
      end
      
      puts UFO::DISPLAY[@incorrect_guesses]
      puts "Incorrect Guesses:"
      # puts need to display all incorrect guesses in order of guess
      puts
      puts "Codeword:"
      puts @codeword_display.join(" ")
      puts @codeword_display.length
      puts @codeword
      
      puts "Please enter your guess: "
      @curr_guess = gets.chomp
      # validate guess
      
      # check if guess is correct
      if !is_guess_correct?()
        @incorrect_guesses += 1
      end
    end

    puts UFO::DISPLAY[@incorrect_guesses]
    puts "GAME OVER!"
    # play again? 

  end
  
end


# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.render
end