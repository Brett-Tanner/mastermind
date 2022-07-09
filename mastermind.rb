# TODO: persist score TODO: between each game TODO:
    # codemaker module

        # gains a point each time the codebreaker guesses incorrectly, plus one more if they run out of turns

class Game

    private

    attr_accessor :player1, :player2, :num_of_games, :board, :players, :code, :guess_number
    
    def initialize
        player1_name = self.get_player_name(1)
        player2_name = self.get_player_name(2)
        
        player1_role = self.get_player_role(player1_name)
        player2_role = self.get_player_role(player2_name)
        if player1_role == player2_role
            puts "***You can't have the same role***"
            player1_role = self.get_player_role(player1_name)
            player2_role = self.get_player_role(player2_name)
        end

        @player1 = self.create_player(player1_name, player1_role)
        @player2 = self.create_player(player2_name, player2_role)

        @players = [@player1, @player2]

        puts "How many games will you play??"
        @num_of_games = gets.chomp.to_i
        
        # needs to be initilialized as an array so the clear in .new_board doesn't throw an error
        @board = Array.new
        @guess_number = 0
        self.set_code
    end

    def get_player_name(player_num)
        puts "Player #{player_num}, what's your name? Enter 'CPU' to create a computer player"
        gets.chomp
    end

    def get_player_role(player_name)
        puts "#{player_name}, what's your role? (CM or CB)"
        gets.chomp.downcase
    end

    def create_player(player_name, player_role)
        if player_role == "CPU"
            Computer.new(player_role)
        else
            Human.new(player_name, player_role)
        end
    end

    def set_code
        @players.each do |player|
            if player.role == "cm"
                puts "#{player.name}, set your code"
                @code = gets.chomp
                unless self.is_valid?(@code)
                    self.set_code
                    return 
                end
            end
        end

        @code = @code.split(//)

        self.new_board
        if @player1.role == "cb"
            self.make_guess(@player1)
        else
            self.make_guess(@player2)
        end
    end

    def is_valid?(input)
        if input.length != 4
            puts "***The code must be 4 digits***"
            return false
        end
        if input.split(//).all? {|digit| digit.to_i > 0 && digit.to_i < 7}
            true
        else
            puts "**Digits can only be between 0-6***"
            false
        end
    end

    def new_board
        @board.clear
        12.times {@board.push(["o", "o", "o", "o", "|", "0", "0", "0", "0"])}
        self.print_board
    end

    def print_board
        @board.each {|value| puts value.join("  ")}
    end

    def make_guess(guessing_player)
        puts "#{guessing_player.name}, what do you think the code is?"
        guess = gets.chomp
        unless self.is_valid?(guess)
            self.make_guess(guessing_player)
            return
        end
        guess = guess.split(//)

        @code.each_index do |column|
            if @code[column] == guess[column]
                puts "Digit #{column} is exactly right!"
                @board[@guess_number][column] = "b"
            elsif @code.any?(guess[column])
                puts "Digit #{column} is right, but in the wrong place!"
                @board[@guess_number][column] = "w"
            else
                puts "Digit #{column} isn't part of the code"
            end
            @board[@guess_number][column + 5] = guess[column]
        end

        if guess == @code
            puts "Congratulations #{guessing_player.name}, you got it!"
            self.reset_game
            return
        else
            # update score
        end

        self.print_board
        
        @guess_number += 1
        if @guess_number > 11
            puts "Oh no, you're out of guesses! The code was #{@code.join}"
            self.reset_game
        else
            puts "#{12 - @guess_number} guesses remaining"
            self.make_guess(guessing_player)
        end
    end

    def reset_game 
        if @num_of_games > 1 # because you play one initially
            @num_of_games -= 1
            if @num_of_games == 1
                puts "#{num_of_games} game remaining!"
            else
                puts "#{num_of_games} games remaining!"
            end
            # switch roles
            old_p1 = @player1.role
            old_p2 = @player2.role
            @player1.role = old_p2
            @player2.role = old_p1
            @guess_number = 0
            self.new_board
            self.set_code
        else
            exit(0)
        end
    end
end

class Human
    
    attr_accessor :role, :name, :score

    private

    def initialize(name, role)
        @name = name
        @role = role
        @score = 0
    end
end

class Computer
    
    attr_accessor :role, :name, :score
    
    private

    def initialize(role)
        @name = "CPU"
        @role = role
        @score = 0
    end
end

test = Game.new