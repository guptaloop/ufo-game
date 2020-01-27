require 'set'
require_relative 'assets/ufo'

class Game
  attr_reader :codeword, :alphabet, :guessed, :incorrect_guesses

  def initialize
    @codeword = gen_codeword()
    # use Sets for faster lookup
    @alphabet = Set.new | ('a'..'z')
    @guessed = Set.new
    @incorrect_guesses = 0
  end

  def gen_codeword
    # convert nouns.txt to an array of strings
    words = []
    File.readlines('assets/nouns.txt').map do |line|
      words << line
    end
    # randomly choose the codeword from the words array
    return words.sample
  end

  def codeword_key
    key = ""
    (@codeword.length - 1).times do
      key += "_ "
    end
    return key
  end

  def render
    if @incorrect_guesses < 1 && @guessed.empty?
      puts 
      puts "UFO: The Game"
      puts "Instructions: save us from alien abduction by guessing letters in the codeword."
      puts 
      puts UFO::DISPLAY[@incorrect_guesses]
      puts
      puts "Incorrect Guesses:"
      puts "None"
      puts
      puts "Codeword:"
      puts codeword_key()
      puts
    else

    end

    puts @codeword
    puts
    # puts @alphabet
    # puts @guessed
  end
  
end


# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.render
end