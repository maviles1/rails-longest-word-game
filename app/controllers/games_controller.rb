require 'open-uri'

class GamesController < ApplicationController
  def new
    rand_grid = []
    10.times do
      rand_grid.push(randomize.upcase)
    end
    @grid = rand_grid
    @str = ""
    @grid.each do |x|
      @str += "#{x} "
    end
  end

  def score
    @final_score = run_game(params["entry"], params["grid"].split(' '))
  end

   def randomize
      alphabet_array = ("a".."z").to_a

      random = rand(0...26)
      return alphabet_array[random]
    end

  def run_game(attempt, grid)
    game_hash = { score: 0, message: "" }
    if used_once(attempt, grid) && in_dictionary(attempt)
      game_hash[:score] = attempt.length
    elsif !used_once(attempt, grid) && in_dictionary(attempt) && valid_word(attempt, grid)
      game_hash[:message] = "Letters are overused"
    elsif !valid_word(attempt, grid) && in_dictionary(attempt)
      game_hash[:message] = "Your word is not in the grid"
    elsif !in_dictionary(attempt)
      game_hash[:message] = "Not an english word"
    end
    return game_hash
  end

  def valid_word(word, grid)
    bool = true
    word.split('').each do |x|
      if grid.include? x.upcase
        grid.delete(x)
      else
        bool = false
      end
    end
    return bool
  end

  def in_dictionary(word)
    word_hash = {}
    URI.open("https://wagon-dictionary.herokuapp.com/#{word}") do |x|
      x.each_line do |line|
        word_hash = JSON.parse(line)
      end
    end
    return word_hash["found"] == true
  end

  def used_once(word, grid)
    if valid_word(word, grid)
      word.split('').each do |x|
        if grid.include? x.upcase
          grid.delete_at(find_index(x, grid))
        else
          return false
        end
      end
      return true
    else
      return false
    end
  end

  def find_index(char, grid)
    grid.each_with_index do |x, i|
      return i if char.upcase == x
    end
  end

  end
