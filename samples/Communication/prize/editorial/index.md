# The Big Prize

## Subtask 1

In this subtask, We can find the diamond with a simple binary search.

## Subtask 2

First we query the first 474 prize in the line. It’s sufficient to find at least a lollipops prize (cheapest). When we have found a lollipop, we can use binary search to find all prize except lollipops. This approach needs less than 9000 queries.
The number of queries required is $O(\sqrt{n} \times \log{n})$ but there are exists another way which leads to less queries:

Find a lollipop. Then use devide and conquer: ask the middle of segment until finding new lollipop. then devide the segment into two segment and keep the number of prizes which aren't lollipop. 
choose another random frog. If they are both young we know with the
current information if there are any older frogs between them. If there exists we can recursively
solve the interval between them. This approach needs at most 3000 queries.
