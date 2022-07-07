# TODO: persist score between each game    

class Game

    @@BLANK_HINTS = ["o", "o", "o", "o", "|"]
    @@BLANK_ROW = ["0", "0", "0", "0"]
    @@board = []

    attr_accessor :player1, :player2, :num_of_rounds, :board
    
    def initialize
        puts "Player 1, what's your name"
        player1_name = gets.chomp
        puts "#{player1_name}, what's your role?"
        player1_role = gets.chomp.downcase
        puts "Player 2, what's your name (Enter 'CPU' to play against the computer)"
        player2_name = gets.chomp
        puts "#{player2_name}, what's your role?"
        player2_role = gets.chomp.downcase
        
        if player2_name == "CPU"
            @player1 = Human.new(player1_name, player1_role)
            @player2 = Computer.new(player2_role)
        else
            @player1 = Human.new(player1_name, player1_role)
            @player2 = Human.new(player2_name, player2_role)
        end

        puts "Best of _?"
        @num_of_rounds = gets.chomp.to_i
        self.set_code
    end

    def set_code
        
        self.new_board
    end

    def new_board
        12.times {@@board.push([@@BLANK_HINTS, @@BLANK_ROW])}
        self.print_board
    end

    def print_board
        @@board.each {|value| puts value.join("  ")}
    end
end

class Human
    
    attr_accessor :role, :name

    def initialize(name, role)
        @name = name
        @role = role
    end
end

class Computer
    
    attr_accessor :role, :name
    
    def initialize(role)
        @name = "CPU"
        @role = role
    end
end


# can you include and exclude modules through a method????

    # codemaker module

        # chooses 4 colored pegs (if comp they're random)

        # gains a point each time the codebreaker guesses incorrectly, plus one more if they run out of turns


    # codebreaker module

        # tries to guess order/color (by placing colored pegs in 4 large holes)


        # checks against codemaker's choice (black small peg for color and position correct, white peg is the right color in the wrong place)

        # guess until all rows are full

test = Game.new