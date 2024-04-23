local currentPlayer = "X"
local board = {
    { "", "", "" },
    { "", "", "" },
    { "", "", "" }
}

local gameState = "playing"

local font = love.graphics.newFont(20)

local queueX = {}
local queueO = {}
local countX = 0
local countO = 0

function love.load()
    love.window.setTitle("Tic Tac Toe")
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setFont(font)

    WindowWidth = love.graphics.getWidth()
    WindowHeight = love.graphics.getHeight()

    CellSize = 100
    Margin = 10

    GridWidth = 3 * CellSize + 2 * Margin
    GridHeight = 3 * CellSize + 2 * Margin

    GridX = (WindowWidth - GridWidth) / 2
    GridY = (WindowHeight - GridHeight) / 2
end

function love.draw()
    for row = 1, 3 do
        for col = 1, 3 do
            local x = GridX + (col - 1) * (CellSize + Margin)
            local y = GridY + (row - 1) * (CellSize + Margin)

            -- Check if the queue is full and the current cell is the first element to be removed for X
            local isFirstToRemoveX = false
            if gameState == "playing" and #queueX >= 3 then
                local firstX = queueX[1]
                if firstX[1] == row and firstX[2] == col then
                    isFirstToRemoveX = true
                end
            end

            -- Check if the queue is full and the current cell is the first element to be removed for O
            local isFirstToRemoveO = false
            if gameState == "playing" and #queueO >= 3 then
                local firstO = queueO[1]
                if firstO[1] == row and firstO[2] == col then
                    isFirstToRemoveO = true
                end
            end

            -- Draw the cell with adjusted opacity if it's the first element to be removed for X or O
            if isFirstToRemoveX or isFirstToRemoveO then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle("line", x, y, CellSize, CellSize)

                local cellContent = board[row][col]
                if cellContent == "X" then
                    DrawX(x, y)
                elseif cellContent == "O" then
                    DrawO(x, y)
                end
            else
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("line", x, y, CellSize, CellSize)

                local cellContent = board[row][col]
                if cellContent == "X" then
                    DrawX(x, y)
                elseif cellContent == "O" then
                    DrawO(x, y)
                end
            end
        end
    end

    if gameState == "X wins" or gameState == "O wins" then
        love.graphics.setColor(0.9, 0, 1)
        love.graphics.print(gameState .. "!", GridX, GridY + GridHeight + 20)
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("PRESS ANY KEY TO PLAY AGAIN", GridX, GridY + GridHeight + 40)
    elseif gameState == "draw" then
        love.graphics.setColor(0.9, 0, 1)
        love.graphics.print("Draw!", GridX, GridY + GridHeight + 20)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("PRESS ANY KEY TO PLAY AGAIN", GridX, GridY + GridHeight + 40)
    end
end

function love.keypressed(key)
    if gameState == "X wins" or gameState == "O wins" or gameState == "draw" then
        ResetGame()
    end
end

function DrawX(x, y)
    love.graphics.line(x + 10, y + 10, x + CellSize - 10, y + CellSize - 10)
    love.graphics.line(x + CellSize - 10, y + 10, x + 10, y + CellSize - 10)
end

function DrawO(x, y)
    love.graphics.circle("line", x + CellSize / 2, y + CellSize / 2, CellSize / 2 - 10)
end

function CheckWin(player)
    for i = 1, 3 do
        if (board[i][1] == player and board[i][2] == player and board[i][3] == player) or
            (board[1][i] == player and board[2][i] == player and board[3][i] == player) then
            return true
        end
    end

    if (board[1][1] == player and board[2][2] == player and board[3][3] == player) or
        (board[1][3] == player and board[2][2] == player and board[3][1] == player) then
        return true
    end

    return false
end

function CheckDraw()
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == "" then
                return false
            end
        end
    end
    return true
end

function ResetGame()
    love.graphics.setColor(1, 1, 1)
    board = {
        { "", "", "" },
        { "", "", "" },
        { "", "", "" }
    }
    currentPlayer = "X"
    gameState = "playing"
    queueX = {}
    queueO = {}
    countX = 0
    countO = 0
end

function love.mousepressed(x, y, button)
    if gameState == "playing" then
        if button == 1 and x >= GridX and x <= GridX + GridWidth and y >= GridY and y <= GridY + GridHeight then
            local row = math.floor((y - GridY) / (CellSize + Margin)) + 1
            local col = math.floor((x - GridX) / (CellSize + Margin)) + 1

            if board[row][col] == "" then
                board[row][col] = currentPlayer
                if currentPlayer == "X" then
                    countX = countX + 1
                    table.insert(queueX, { row, col })
                    if countX > 3 then
                        local firstGrid = table.remove(queueX, 1)
                        board[firstGrid[1]][firstGrid[2]] = ""
                    end
                else
                    countO = countO + 1
                    table.insert(queueO, { row, col })
                    if countO > 3 then
                        local firstGrid = table.remove(queueO, 1)
                        board[firstGrid[1]][firstGrid[2]] = ""
                    end
                end

                if CheckWin(currentPlayer) then
                    gameState = currentPlayer .. " wins"
                elseif CheckDraw() then
                    gameState = "draw"
                else
                    currentPlayer = currentPlayer == "X" and "O" or "X"
                end
            end
        end
    elseif gameState == "X wins" or gameState == "O wins" or gameState == "draw" then
        if button == 1 and x >= GridX and x <= GridX + GridWidth and y >= GridY + GridHeight + 20 and y <= GridY + GridHeight + 40 then
            ResetGame()
        end
    end
end
