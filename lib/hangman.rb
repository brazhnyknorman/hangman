require 'yaml'

def clean_dictionary
  possible_words = []
  File.readlines('dictionary.txt').each do |line|
    possible_words.push(line) if line.chomp.length.between?(5, 11)
  end
  possible_words
end

def generate_word(possible_words)
  possible_words.sample
end

# Creates class that produces objects to track an individual game of hangman
class Game
  attr_accessor :random_word, :user_word, :guess_count, :revealed

  def initialize
    @random_word = generate_word(clean_dictionary).chomp
    @guess_count = 6
    @user_word = nil
    @revealed = '*' * @random_word.length
  end

  def guesses_left
    puts "You have #{guess_count} guesses left"
  end

  def check_guess(guess)
    if guess.downcase == @random_word
      puts 'You won!'
      exit
    elsif guess == 'savegame'
      save_game
    elsif guess == 'loadgame'
      load_game
    else
      hint(guess)
    end
  end

  def hint(guess)
    (0..(random_word.length - 1)).each do |i|
      if @random_word[i] == guess[0]
        @revealed[i] = guess[0]
      end
    end
    if @random_word == @revealed
      puts "You Won! The word was #{@random_word}."
      exit
    end

    puts "\n\nYou currently have #{@revealed}.\n"
    @guess_count -= 1 unless @revealed.include?(guess)
  end

  def game_over?
    guess_count.zero?
  end

  def save_game
    File.open('saves.yaml', 'w') do |f|
      f.write(YAML.dump(self))
    end
  end

  def load_game
    load_data(YAML.safe_load(File.open('saves.yaml', 'r'), permitted_classes: [self.class]))
  end

  def load_data(obj)
    @random_word = obj.random_word
    @guess_count = obj.guess_count
    @user_word = obj.user_word
    @revealed = obj.revealed
  end
end

game = Game.new

puts 'Welcome to Hangman! A game so well known that it needs no introduction.'
puts 'To save the game, type in savegame at any time!'
puts 'Enter loadgame to load a previous game.'

until game.game_over? == true
  print 'Enter your guess: '
  game.check_guess(gets.chomp)
  game.guesses_left
end

puts "You lose! womp womp. The word was #{game.random_word}"
