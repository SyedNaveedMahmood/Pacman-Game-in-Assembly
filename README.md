Goriber PAC-MAN is a minimalist implementation of the classic PAC-MAN game, built in Assembly language for DOS systems. Navigate through a grid, collect 'S' characters to increase your score, and avoid the 'G' ghosts that chase you. The game features a lives system, allowing you to continue playing after being caught by a ghost, and rewards players with extra lives for reaching score milestones.

## Features

- Grid-based movement system with W/A/S/D controls
- Ghost enemies that pursue the player
- Score system with collectable 'S' items
- Lives system with continuation option
- High score tracking
- Extra life awarded for every 10 points
- Bengali-inspired welcome messages (Goriber PAC-MAN = "Poor man's PAC-MAN")

## Requirements

To run this game, you'll need:
- A DOS environment or DOS emulator (like DOSBox)
- An x86 Assembly compiler (like MASM, TASM)
- 16-bit support

## Installation

1. Clone this repository
   ```
   git clone https://github.com/yourusername/goriber-pacman.git
   ```

2. Compile the assembly file
   ```
   masm pacman.asm;
   link pacman;
   ```

3. Run the executable
   ```
   pacman.exe
   ```

## How to Play

1. Launch the game and press 'Y' at the welcome screen to start
2. Use the following controls to play:
   - W: Move up
   - A: Move left
   - S: Move down
   - D: Move right
   - Q: Quit game
3. Collect 'S' characters to increase your score
4. Avoid 'G' ghosts - they will chase you!
5. Get 10 points to earn an extra life
6. When caught by a ghost, press Y to continue (if you have lives remaining) or N to end the game

## Game Mechanics

- The game is played on a bordered grid
- The player ('P') starts in the middle of the grid
- Score points ('S') appear randomly on the grid
- Ghosts ('G') spawn periodically and chase the player
- Ghosts move toward the player with each player move
- New ghosts spawn after every two player moves
- Each game starts with 3 lives
- An extra life is awarded for every 10 points collected
- High score is stored between game sessions

## Screenshots

(Add screenshots here if available)

## Development

This game was developed using 16-bit x86 Assembly language with macros and procedures for maintaining code organization. The code structure includes:

- Macros for common tasks like printing newlines
- Procedures for game initialization and main gameplay loop
- Ghost AI using simple player tracking
- Random number generation for ghost and score item placement
- Screen drawing and input handling routines

## Author

Syed Naveed Mahmood
Jareen Tasneem Khondaker
Farhan Tawseef

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the classic PAC-MAN arcade game
- Developed as a learning project for Assembly programming
