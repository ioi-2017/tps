# Nowruz Editorial

## Abstract

* Input: an $m \times n$ grid. Some random cells are blocked.
* Output: A tree such that its nodes are a subset of free cells of the grid.
The tree should have as much leaves as possible (a solution is graded based on the number of leaves of the tree).

## Solutions for empty grid

One easy approach is to build some patterns that have many leaves, such as below (all of which in an empty $35 \times 35$ grid):

Maze | Description
--- | ---
![Haircomb](haircomb.png=200x200) | A hair comb with $386$ leaves.
![Snail](snail.png=200x200) | A snail with $386$ leaves.


Unexpectedly, the following code generates a nice [Sierpinski fractal](https://en.wikipedia.org/wiki/Sierpinski_triangle) with $148$ leaves:
```
mark[1][1] = true
scan the whole grid, starting from (1,1):
    mark each cell that has exactly 1 marked neighbor
return mark
```

![Sierpinski](sierpinski.png=300x300)

But the optimal solution we have so far for this grid can be obtained by a simple change on the above code. It is a nice fractal with $408$ leaves:
```
mark[1][1] = true
loop
    scan the whole grid:
        mark each cell that has exactly 1 marked neighbor
until mark values are not changed
return mark
```

![Fractal](fractal.png=300x300)

## Solutions for grid with random blocks

The solution above can be adopted to work for grids with random blocks:

```
do the following search several times:
    unmark all cells
    select a random free cell and set its mark true
    loop:
        scan all cells in random order:
            mark each free cell that has exactly 1 marked neighbor
    until nothing changes
return the best answer
```

This solution could score for 86 points with the actual test data of the contest.

![Random Fractal](random.png=400x400)

Another idea is to pick a random free cell to initiate the tree, and keep expanding it as long as possible.
Expanding operation: Pick a free cell that is adjacent to exactly one of the tree cells so far,
add this cell and all of its adjacent cells that can be added and become leaves to the tree.
At each moment, expand the tree where it adds the highest number of leaves. Note that in each
operation, 1 to 5 cells will be added to the tree. This solution gets 99+ percent.
