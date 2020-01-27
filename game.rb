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
    words = File.readlines('assets/nouns.txt').map do |line|
      line.split.map(&:to_s)
    end
    # randomly choose the codeword from the words array
    return words.sample
  end

  def render
    puts ""
    puts "UFO: The Game"
    puts "Instructions: save us from alien abduction by guessing letters in the codeword."
    puts ""
    puts "UFO TEXT"

    puts UFO::DISPLAY[0]
    # render the UFO

    # puts @codeword
    # puts @alphabet
    # puts @guessed
  end
  
end


# starts a new game when <ruby game.rb> is run in CLI
if $PROGRAM_NAME == __FILE__
  Game.new.render
end