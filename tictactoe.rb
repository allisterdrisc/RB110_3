WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]
INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_SCORE = 5

def prompt(msg)
  puts "=> #{msg}"
end

def display_rules
  prompt 'Welcome to Tic-Tac-Toe!'
  prompt 'To win a round, get 3 in a row.'
  prompt "First to #{WINNING_SCORE} wins!"
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts ''
  puts '     |     |'
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts '     |     |'
  puts '-----+-----+-----'
  puts '     |     |'
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts '     |     |'
  puts '-----+-----+-----'
  puts '     |     |'
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts '     |     |'
  puts ''
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def joinor(arr, delimiter = ', ', word = 'or')
  case arr.size
  when 0 then ''
  when 1 then arr.first.to_s
  when 2 then arr.join(" #{word} ")
  else
    arr[-1] = "#{word} #{arr.last}"
    arr.join(delimiter)
  end
end

def who_chooses_first
  user_choice = nil
  loop do
    prompt 'Do you want to decide who goes first or me to?'
    prompt "Enter '1' to choose"
    prompt "Enter '2' to have computer choose"
    user_choice = gets.chomp.to_i
    break if (user_choice == 1) || (user_choice == 2)

    prompt "That's invalid. Please enter 1 or 2."
  end
  user_choice
end

def who_goes_first(person_choosing)
  if person_choosing == 1
    answer = nil
    loop do
      prompt 'Do you want to go first this round? (y or n)'
      answer = gets.chomp.downcase
      break if 'yn'.include?(answer)
    end
    answer == 'y' ? 'Player' : 'Computer'
  else
    %w[Player Computer].sample
  end
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square: #{joinor(empty_squares(brd))}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)

    prompt "Sorry, that's an invalid choice."
  end
  brd[square] = PLAYER_MARKER
end

def find_at_risk_square(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  else
    nil
  end
end

def computer_places_piece!(brd)
  square = nil

  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, PLAYER_MARKER)
    break if square
  end

  unless square
    WINNING_LINES.each do |line|
      square = find_at_risk_square(line, brd, COMPUTER_MARKER)
      break if square
    end
  end

  unless square
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def make_a_move!(brd, current_player)
  current_player == 'Player' ? player_places_piece!(brd) : computer_places_piece!(brd)
end

def swap_player(player)
  player == 'Player' ? 'Computer' : 'Player'
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(line[0], line[1], line[2]).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(line[0], line[1], line[2]).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def detect_winning_score(player_score, computer_score)
  if player_score == WINNING_SCORE
    'Player'
  elsif computer_score == WINNING_SCORE
    'Computer'
  else
    nil
  end
end


player_score = 0
computer_score = 0

loop do
  system 'clear'
  display_rules
  loop do
    users_choice = who_chooses_first
    active_player = who_goes_first(users_choice)
    board = initialize_board

    loop do
      display_board(board)
      make_a_move!(board, active_player)
      active_player = swap_player(active_player)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board)

    if someone_won?(board)
      prompt "#{detect_winner(board)} won!!"
    else
      prompt "It's a tie!"
    end

    if detect_winner(board) == 'Player'
      player_score += 1
    elsif detect_winner(board) == 'Computer'
      computer_score += 1
    end

    prompt "Player: #{player_score} Computer: #{computer_score}"

    if detect_winning_score(player_score, computer_score)
      prompt "#{detect_winning_score(player_score, computer_score)} is first to 5!!"
      player_score = 0
      computer_score = 0
      break
    end
  end

  prompt 'Play again? (y or n)'
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt 'Thanks for playing Tic Tac Toe, bye!'
