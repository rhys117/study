
def prompt(msg)
  puts "=> #{msg}"
end

VALID_CHOICES = %w(rock paper scissors spock lizard)

WHO_WINS = { "rock" => %w(lizard scissors),
             "paper" => %w(rock spock),
             "scissors" => %w(paper lizard),
             "lizard" => %w(spock paper),
             "spock" => %w(scissors rock) }

def win?(first, second)
  WHO_WINS[first].include?(second)
end

def display_result(player, computer)
  if win?(player, computer)
    prompt "You won this round!"
    return 'player'
  elsif win?(computer, player)
    prompt "Computer won this round!"
    return 'computer'
  else
    prompt "It's a tie this round!"
    return 'tie'
  end
end

def score(player, computer)
  "Your score: #{player}; Computer's score: #{computer}".chomp
end

def short_hand(choice)
  return 'rock' if choice[0] == 'r'
  return 'paper' if choice[0] == 'p'
  return 'scissors' if choice[0, 2] == 'sc'
  return 'lizard' if choice[0] == 'l'
  return 'spock' if choice[0, 2] == 'sp'
  return 'quit' if choice[0] == 'q'
end

prompt "Welcome to rock, paper, scissors, lizard, spock!"

player_win_count = 0
computer_win_count = 0
game_counter = 0
results = []

loop do # main loop
  player_choice = ''
  loop do # player chooses
    prompt "What do you choose, #{VALID_CHOICES.join(', ')}? (q to quit)"
    player_choice = gets.chomp.downcase

    player_choice = short_hand(player_choice)

    break if player_choice == 'quit'

    if VALID_CHOICES.include?(player_choice)
      break
    else
      prompt "That's not a valid choice"
    end
  end

  break if player_choice == 'quit'

  computer_choice = VALID_CHOICES.sample

  results = [player_choice, computer_choice]
  sleep(0.5)

  prompt "You chose: #{player_choice}; Computer chose: #{computer_choice}"
  # Displays both choices
  sleep(0.5)

  case results.sort # Case to display how the game was won
  when %w(lizard rock)
    prompt 'rock crushes lizard'
  when %w(lizard paper)
    prompt 'lizard eats paper'
  when %w(lizard spock)
    prompt 'lizard poisens spock'
  when %w(lizard scissors)
    prompt 'scissors decapitates lizard'
  when %w(paper scissors)
    prompt 'scissors cuts paper'
  when %w(paper spock)
    prompt 'paper disproves spock'
  when %w(paper rock)
    prompt 'paper covers rock'
  when %w(rock spock)
    prompt 'spock vaporizes rock'
  when %w(rock scissors)
    prompt 'rock crushes scissors'
  when %w(scissors spock)
    prompt 'spock smashes scissors'
  else
    prompt 'they cancelled each other out'
  end
  sleep(0.5)

  display_result(player_choice, computer_choice) # Displays who won
  sleep(0.5)

  if game_counter.zero?
    prompt "Would you like to play a best of five? y for yes"
    best_of_5 = gets.chomp
    sleep(0.5)
    break unless best_of_5.downcase.start_with?('y')
  end

  if win?(player_choice, computer_choice)
    player_win_count += 1
  elsif win?(computer_choice, player_choice)
    computer_win_count += 1
  end
  prompt score(player_win_count, computer_win_count)
  sleep(0.5)

  if player_win_count == 3
    prompt "You won the game!"
  elsif computer_win_count == 3
    prompt "The computer won the game!"
  end

  if player_win_count == 3 || computer_win_count == 3
    prompt "Would you like to play again? y for yes"
    game_reset = gets.chomp
    break unless game_reset.start_with?('y')
    player_win_count = 0
    computer_win_count = 0
    game_counter = 0
  end

  results = []
  game_counter += 1
end

prompt "Thanks for playing #{VALID_CHOICES.join', '}"
