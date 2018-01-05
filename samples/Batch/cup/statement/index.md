# Cup of Jamshid 

Jamshid, a great king of ancient Persia, is looking for the cup of divination, a miraculous cup through which one could observe all over the universe. He has asked Shahrasb, a great wizard who lives in Alborz mountains, for his help. 

Shahrasb told Jamshid that the cup is hidden somewhere in the Great Salt Desert, a large desert in the middle of ancient Persia, but he doesn't know its exact location. Furthermore, Jamshid can ask him several questions. 
In each question, Jamshid selects a point anywhere in Persia (inside or outside of the desert), and Shahrasb can use his magical powers to find the Katouzian distance between the cup and the selected point. 

Each point in Persia has integer $x$ and $y$ coordinates in the range  $[-10^9, 10^9]$. The desert is a square region in the center, with $x$ and $y$ coordinates in the range $[-5 \times 10^8, 5 \times 10^8]$. 
The Katouzian distance between two points $(x, y)$ and $(p, q)$ is calculated as $|x - p| \oplus |y - q|$,
 where $|x - p|$ is the absolute value of $(x-p)$, and $\oplus$ indicates bitwise XOR (exclusive OR).

Your task is to help Jamshid find the cup by asking Shahrasb a number of questions.

## Implementation details

There are $T$ different scenarios, numbered $0$ through $T-1$.
The coordinates of the cup in scenario $i$ (for $0 \leq i \leq T-1$) is $(a[i], b[i])$. 
You should implement the following procedure:

```
int[] find_cup()
```
* This procedure will be called $T$ times, once for each scenario. 
* In scenario $i$ (for $0 \leq i \leq T-1$), the procedure must return an array $c$ of length $2$, such that $c[0]=a[i]$ and $c[1]=b[i]$.

To implement the above procedure, you can call the following procedure:
```
int ask_shahrasb(int x, int y)
```
* $x$ and $y$: the coordinates of the selected point. Both coordinates should be integer values in the range $[-10^9, 10^9]$. 
* This procedure returns the Katouzian distance between the cup and the point $(x, y)$.

## Example

Consider `find_cup()` is called, and the cup is hidden at the point $(1,3)$. The implementation of `find_cup()` makes the following procedure calls:
* `ask_shahrasb(4, 1)` returns $1$.
* `ask_shahrasb(0, 2)` returns $0$.
* `ask_shahrasb(-1, 0)` returns $1$.
* Now the location of the cup is uniquely determined, and `find_cup()` returns $[1,3]$.

## Constraints

* $1 \leq T \leq 1000$,
* $-5 \times 10^8 \leq a[i], b[i] \leq 5 \times 10^8$.

## Scoring

Your score will be $0$ if the return value of `find_cup()` is incorrect for any of the scenarios. Otherwise, your score will be computed as below ($Q$ is the maximum number of questions asked among all scenarios).

| Condition | Score |
| :---: | :---: | 
| $1000 < Q $ | $0$ |
| $104 < Q \leq 1000$ | $20$ |
| $70 < Q \leq 104$ | $30$ |
| $39 < Q \leq 70$ | $61$ |
| $32 < Q \leq 39$ | $132-Q$ |
| $Q \leq 32$ | $100$ |


## Sample grader

The sample grader reads the input in the following format:
* line $1$: $\;\;T$
* line $2 + i$ (for $0 \le i \le T-1$): $\;\;a[i]\;\;b[i]$

For each scenario, the sample grader prints a single integer in a separate line: the number of calls to `ask_shahrasb()` in the scenario, or $-1$ if the return value of `find_cup()` was incorrect.

