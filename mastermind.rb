# ask how many games they want to play, set that as the number of games to be played

# keep score over each game    


# 12 rows of 4 holes, with 4 smaller holes next to them


    # 6 colors to be placed in the large holes TODO: Use numbers, not colors


    # 4 smaller black and white pegs for the smaller holes

class Game
    
    attr_accessor :player1, :player2, :num_of_rounds
    
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

Game.new