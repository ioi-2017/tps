# Solution

## Subtask 1
There are many different $O(n^2)$ or $O(n^3)$ dp solutions for this subtask.
The simplest one is to define $dp\_{i, j}$ as the minimum cost needed for wiring the first $i$ red points and the first $j$ blue points. 
Update is like $dp\_{i, j} = \min(dp\_{i - 1, j}, dp\_{i, j - 1}, dp\_{i - 1, j - 1}) + |red_i - blue_j|$.

## Subtask 2
This subtask is to find the pattern of wiring. The simple solution to this subtask is to calculate $\sum\_0 ^{n-1} (red\_{n-1} - red\_i) + \sum\_0^{m-1} (blue\_i - blue\_0) + \max(n, m) \times (blue[0] - red[n - 1])$.

## Subtask 3
Consider the consecutive clusters of points with the same color. The idea is each wire will have endpoints in two consecutive clusters, so the $O(n^2)$ solutions could be optimized to $O(n \times MaxBlockSize)$.

## Subtask 4
This subtask could be solve greedily, halving each cluster and connecting left half to the left cluster and right half to the right cluster. The middle point of clusters with odd number of points should be considered separately.

## Full solution
There is $O(n + m)$ $dp$ solution: Let $dp_i$ be the minimum total distance of a valid wiring scheme for the set of points that are less than or equal to a given point $i$. This could be updated with amortized time complexity $O(1)$.
