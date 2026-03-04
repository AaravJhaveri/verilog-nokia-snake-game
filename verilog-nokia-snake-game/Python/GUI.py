from tkinter import *
import subprocess



# defining functions:

def isTail(row, col):
    # check if the snake part at the given coords is a tail or not
    global board
    # return if the current element is not on the snake
    if board[row][col] != "S":
        return False
    # count the number of snake parts around the current part
    return 1 == sum((board[row + d[0]][col + d[1]] in "SH") for d in [(-1,0), (1,0), (0,-1), (0,1)] if 0 <= row + d[0] < len(board) and 0 <= col + d[1] < len(board[0]))

def getDir(row ,col):
    # check the direction of the head wrt the next snake part
    global board
    if board[row - 1][col] == "S" or board[row - 1][col] == "H":
        return "u" # if the snake is pointing downwards
    elif board[row + 1][col] == "S" or board[row + 1][col] == "H":
        return "d" # if the snake is pointing upwards
    elif board[row][col - 1] == "S" or board[row][col - 1] == "H":
        return "l" # if the snake is pointing right
    elif board[row][col + 1] == "S" or board[row][col + 1] == "H":
        return "r" # if the snake is pointing left
    else:
        return "e" # in case of any discrepancies

def isCell(row, col, cellType):
    global board
    # check if the current cell has the required cell type (be it ".", "A", "H" or "S")
    if (board[row][col] == cellType):
        return True
    return False

def showBoard():
    # main logic
    global board
    
    # delete everything present before
    innerFrame.delete("all")
    
    # again load the board
    loadBoard()
    
    # iterate using two for loops in the gridSize iterable variable
    for i in gridSize:
        for j in gridSize:
            # The default color is blue
            color=BLUE
            if isCell(j, i, "."):
                # In case of an empty cell, the color changes to green
                color=GREEN
                innerFrame.create_rectangle(i*30, j*30, i*30 + 30, j*30 + 30, fill=color, outline=color)
            elif isCell(j, i, "H") or isTail(j, i):
                # If the current element is the head or the tail of the snake, 
                # we add a small curve to the ends of the snake for a better appearance
                
                # First we create the background rectangle
                innerFrame.create_rectangle(i*30, j*30, i*30 + 30, j*30 + 30, fill=GREEN, outline=GREEN)
                
                # then we get the direction of the head or tail (since both are almost the same)
                dir = getDir(j, i)
                
                # now we create blue rectangles which cover only half cell 
                # so that there is only half curve visible instead of a full circle
                if dir == "l":
                    # In this case we start the half rectangle from x = 0 to x = 15 and y covers completely
                    innerFrame.create_rectangle(i*30, j*30, i*30 + 15, j*30 + 30, fill=BLUE, outline=color)
                elif dir == "r":
                    # In this case we start the half rectangle from x = 15 to x = 30 and y covers completely
                    innerFrame.create_rectangle(i*30 + 15, j*30, i*30 + 30, j*30 + 30, fill=BLUE, outline=color)
                elif dir == "u":
                    # In this case we start the half rectangle from y = 0 to y = 15 and x covers completely
                    innerFrame.create_rectangle(i*30, j*30, i*30 + 30, j*30 + 15, fill=BLUE, outline=color)
                elif dir == "d":
                    # In this case we start the half rectangle from x = 15 to y = 30 and x covers completely
                    innerFrame.create_rectangle(i*30, j*30 + 15, i*30 + 30, j*30 + 30, fill=BLUE, outline=color)

                # finally we create the circle to give a smooth half curve
                innerFrame.create_oval(i*30, j*30, i*30 + 30, j*30 + 30, fill=BLUE, outline=BLUE)
            elif isCell(j, i, "A"):
                # In this case we make the apple a circle while having a green background
                innerFrame.create_rectangle(i*30, j*30, i*30 + 30, j*30 + 30, fill=GREEN, outline=GREEN)
                innerFrame.create_oval(i*30, j*30, i*30 + 30, j*30 + 30, fill=RED, outline=RED)
            else:
                # This is when we encounter a part in the snake's body, 
                # now we simply add a rectangle with a blue color (the default one)
                innerFrame.create_rectangle(i*30, j*30, i*30 + 30, j*30 + 30, fill=color, outline=color)

def onButtonClick(dir):
    # this defines what happens when a key is pressed or a button is clicked
    
    # write the direction in the file
    with open("./input.txt", "w") as file:
        file.write(dir)
    try:
        # run the verilog code directly instead of compiling as it won't change anyways
        subprocess.run(["vvp", "tb.vvp"], check=True)
    except subprocess.CalledProcessError as e:
        # print the errors
        print(f"An error occurred: {e}")
    # refresh after verilog completes its part
    showBoard()

def createButton(text, i, j, dir):
    # this function creates a button given the text, coordinates in the grid and the dir which is defined for it.
    global buttonContainer
    button = Button(buttonContainer, text=text, bg="#99ff99", border=1, relief="solid", width=2, height=1, padx=20, pady=20, font=("Arial", 10), command=lambda: onButtonClick(dir))
    button.grid(row=i, column=j)

def bindKey(key, dir):
    # binds the given key to the root (main window) and executes the function on key press
    root.bind(key, lambda event: onButtonClick(dir))

def loadBoard():
    # this function re-assigns the board by reading the output.txt file again
    global board

    with open("./output.txt") as file:
        board = list([i for i in row if (i != "_" and i != "|" and i != "\n")] for row in file.read().split("|\n|"))





# Constants

# Colors:
RED = "#ff5555"
BLUE = "#5555ff"
GREEN = "#55ff55"
LIGHTGREEN = "#55aaaa"

# main board array
board = []

# grid size
n = 20

# iterable grid size
gridSize = range(n)


# define the main window
root = Tk()

# add a title to it
root.title("Nokia Snake Game")

# make it zoomed initially
root.state("zoomed")

# define the main components, in this case, 2 frames, 1 label and 1 canvas
frame = Frame(root, bg="#cccccc")
buttonContainer = Frame(root, bg=LIGHTGREEN, border=1, relief="solid")
titleLabel = Label(frame, text="Nokia Snake Game", bg="#9999ff", font=("Arial", 20), fg="RED", borderwidth=1)
innerFrame = Canvas(frame, highlightbackground="black", highlightthickness=1, width=30*n, height=30*n) # canvas to draw the snake on



# place the components either using grid layout or float layout
frame.place(relx=0.5, rely=0.5, relwidth=0.9, relheight=0.9, anchor="center")
titleLabel.grid(row=0, column=0, sticky="n", ipady=10, pady=20)
innerFrame.grid(row=1, column=0)
buttonContainer.place(relx=0.1, rely=0.5)



# define the columns and rows for those having a grid layout

# columns:
frame.columnconfigure(0, weight=1, uniform="a")
innerFrame.columnconfigure(tuple(gridSize), weight=1, uniform="a")
buttonContainer.columnconfigure((0, 1, 2), weight=1, uniform="a")

# rows:
frame.rowconfigure(0, weight=1, uniform="a")
frame.rowconfigure(1, weight=8, uniform="a")
innerFrame.rowconfigure(tuple(gridSize), weight=1, uniform="a")
buttonContainer.rowconfigure((0, 1, 2), weight=1, uniform="a")



# create the control buttons for the user to click and control the snake
createButton("/\\", 0, 1, "u")
createButton("<", 1, 0, "l")
createButton(">", 1, 2, "r")
createButton("V", 2, 1, "d")
createButton("⟳", 1, 1, "a")



# define what to do on specific key presses
bindKey("<Up>", "u")
bindKey("<Down>", "d")
bindKey("<Left>", "l")
bindKey("<Right>", "r")
bindKey("<a>", "a")



# start the game
showBoard()



# put the window in a loop until it is closed by the user
root.mainloop()
