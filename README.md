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

* A simple word game where players are tasked with choosing a letter such that it forms a valid word fragment from a given dictionary, but also avoids forming a full word [lose case]. Everytime a player loses a round, they accrue a letter, and are knocked out of the game if they reach the code word «not dissimilar to the game HORSE»
***
+ Player Interface
---

* A class that handles player interaction with the game.
* Uses modification of `$stdin` and `$stdout` to allow expansion of the class to accomodate user input from outside the command line
***
+ AI:
---

* So far, I have implemented 3 different AI classes:
####  `AiPlayer` | Brute Force AI
This AI executes a dumb brute force algorithm to eventually find a valid play with no regard to result.
* This algorithm has no concern for presenting unique responses, therefore could have a worse case time complexity of O(∞)

####  `MemorizingAiPlayer` | Smarter Brute Force AI
This AI extends the previous, but maintains a dictionary file of fragments that it knows are valid with no regard to the result
* This algorithm is only faster than it's predecessor if it is encountering a fragment it has seen before.
* This algorithm is faster than `AiPlayer`, but just as likely to lose.

####  `BayesianAiPlayer` | Bayesian Inferance AI
This AI keeps a record of it's outputs that have resulted in valid word fragments, and the number of times that playing a letter resulted in a loss. It then takes those values and calculates a response that is optimized for speed and winning.
* This algorithm will develop a disposition to a certain response
* Due to this, over time, this game outperforms the preceding AI's in both speed and accuracy
* the downside is the AI develops predictable behavior that is harder for an AI to defeat, but easier for a human player to defeat.
***
##  Todo
[]  Extend existing AI classes to make smarter AIs
[]  Refactor the Player Interface into an agnostic agent
[]  Split this project into smaller focused projects