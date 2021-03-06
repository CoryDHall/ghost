# GHOST
# Player Interface
# AI:
+ Brute Force AI
---
+ Smarter Brute Force AI
---
+ Bayesian Inference AI
---
***
+ GHOST
---

* A simple word game where players are tasked with choosing a letter such that it forms a valid word fragment from a given dictionary, but also avoids forming a full word [lose case]. Every time a player loses a round, they accrue a letter, and are knocked out of the game if they reach the code word «not dissimilar to the game HORSE»

[Read More][ghost]
[ghost]: https://en.m.wikipedia.org/wiki/Ghost_(game)
***
+ Player Interface
---

* A class that handles player interaction with the game.
* Uses modification of `$stdin` and `$stdout` to allow expansion of the class to accommodate user input from outside the command line
***
+ AI:
---

* So far, I have implemented 5 different `Ai` classes:


####  `Ai::BruteForce` | Brute Force AI
This AI executes a dumb brute force algorithm to eventually find a valid play with no regard to result.
* This algorithm has no concern for presenting unique responses, therefore could have a worse case time complexity of O(∞)

[Read More][brute force]
[brute force]: https://en.m.wikipedia.org/wiki/Brute-force_search

####  `Ai::Memorizer` | Smarter Brute Force AI
####  `Ai::BetterMemorizer` | Smarter and Lighter Brute Force AI
This AI extends the previous, but maintains a dictionary file of fragments that it knows are valid with no regard to the result
* This algorithm is only faster than it's predecessor if it is encountering a fragment it has seen before.
* As it ages through it's life cycle, this algorithm grows faster than `Ai::BruteForce`, but just as likely to lose.

[Read More][faster brute force]
[faster brute force]: https://en.m.wikipedia.org/wiki/Brute-force_search#Speeding_up_brute-force_searches

####  `Ai::Bayesian` | Bayesian Inference AI
#####   `Ai::BayesianSpeedy`
#####   `Ai::BayesianWinner`
These AIs keep a record of it's outputs that have resulted in valid word fragments, and the number of times that playing a letter resulted in a loss. It then takes those values and calculates an optimized response.
* This algorithm will develop a disposition to a certain response
* Due to this, over time, these AIs outperform the preceding AIs in either speed or accuracy
* the downside is the AIs develop predictable behavior that is harder for `Ai::BruteForce` to defeat, but easier for a human player to defeat.

[Read More][bayesian]
[bayesian]: https://en.m.wikipedia.org/wiki/Bayesian_inference

***
##  Todo
- [ ]  Extend existing AI classes to make smarter AIs
- [ ]  Refactor the Player Interface into an agnostic agent
- [ ]  Split this project into smaller focused projects
