# CraftMyShore
 "Craft My Shore" ported to Godot.

### Map File Format:

An example of a map file can be seen in `map.dat`; each map file contains a grid of tile information specifying the initial state of the gameboard, and optionally may also specify information about game events per turn and a probabibility distribution function for collumn to select for water spawning.

The map grid is a line-seperated 2D-array of tile datums: each row of text represents one row of the game board, and on each row tiles are represented by a single letter (no seperator is used):

- `w` specifies a background water-tile, upon which blocks may be moved.

- `l` specifies an empty plot of land.

- `c` specifies a plot of land which will have a city on it at the beginning of the game.

- `v` specifies a vegetation-spawning tile, which will start the game with vegetation, and will spawn additional vegetation as specified in the game event array.

- `t` specifies a tile which will start with a terrain block.

Additionally, game events may be specified. This is represented as a comma seperated array of integers, where the absolute value of the integer represents how many flood events to roll on that turn, and the sign of the integer whether to spawn vegetation. Eg. `4` would indicate that four new flood blocks would be rolled & appear; `-3` would flood 3 tiles and then attempt to spawn plants on clear vegetation-spawning tiles. The game event array should be placed upon a single line prefixed with the identifier `gea:`, followed by the array. Whitespace may, but needn't, be used between list entries.

The pdf function is specified in the same format, except with the identifier `pdf:` being used; also, entries in the array should be non-negative. Each entry in the pdf array is the numerator in the fractional probability that water will spawn in the corresponding game board collumn, where the denominator is the sum of all numbers in the pdf array. For example, in a 3-collumn map with the pdf `pdf: 1, 2, 4`, water would have a `1/7` chance of spawning in the first collumn, `2/7` in the second, `4/7` in the third.

### Sound Credits:

"themeSong" and "click" by Fin Deevy

wave loop 1.wav by klangfabrik -- https://freesound.org/s/428088/ -- License: Creative Commons 0

Digging in wet course sand (2) by f3bbbo -- https://freesound.org/s/651293/ -- License: Creative Commons 0

Shake by qubodup -- https://freesound.org/s/442892/ -- License: Creative Commons 0

Shake, Pepples, Quick Scurry Low.wav by bbrocer -- https://freesound.org/s/398695/ -- License: Creative Commons 0

Salt shake.wav by xenognosis -- https://freesound.org/s/137245/ -- License: Creative Commons 0

Car horn beep beep two beeps honk honk by AmishRob -- https://freesound.org/s/423990/ -- License: Creative Commons 0

LeavesRustlingFast02 by falcospizaetus -- https://freesound.org/s/489936/ -- License: Creative Commons 0
