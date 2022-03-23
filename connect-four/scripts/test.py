from brownie import accounts, ConnectFour

def main():
    admin = accounts.load('connectfour')
    player1 = accounts.load('player1')
    player2 = accounts.load('player2')

    deployedGame = ConnectFour.deploy({'from': admin})

    deployedGame.createGame({'from': player1})
    deployedGame.joinGame(1, {'from': player2})

    # PLAYER1 moves first
    deployedGame.move(1, 1, False, {'from': player1})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    #  PLAYER2 moves second
    deployedGame.move(1, 2, False, {'from': player2})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    # PLAYER1 moves third
    deployedGame.move(1, 1, False, {'from': player1})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    #  PLAYER2 moves 4th
    deployedGame.move(1, 2, False, {'from': player2})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    # PLAYER1 moves 5th
    deployedGame.move(1, 1, False, {'from': player1})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    #  PLAYER2 moves 6th
    deployedGame.move(1, 2, False, {'from': player2})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)

    # PLAYER1 WINS
    deployedGame.move(1, 1, True, {'from': player1})
    board = deployedGame.viewBoard(1, {'from': admin})
    printBoard(board)



    gameInfo = deployedGame.GAMES.call(1)
    p1 = gameInfo[0]
    p2 = gameInfo[1]
    wager = gameInfo[2]
    blockStart = gameInfo[4]
    blockEnd = gameInfo[5]
    winner = gameInfo[6]

    print(f'\n\nPlayer1: {p1}\tPlayer2: {p2}\n\nWager: {wager}\tWinner:{winner}\n\nStarted: {blockStart}\tEnded: {blockEnd}\n\n')

def printBoard(board):
    for i in reversed(board):
        print(i)