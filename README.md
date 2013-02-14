PLT-Proj
========
Card Game Description Language
==============================
Introduction
============
This document is about the card game language idea. First and foremost we need to make it very clear that it is not poker or blackjack or any card game, which I see people are confusing it with. For ex: VHDL is not a description of some circuit. It is a cirduit description language and any general circuit can be descibed in this language. Likewise this is a card description language and we can make our own little game or one can code a more esoteric game like poker in it. We need to provide enough language constructs and data types which a card game player or developer may be familiar with.

After making this clear we need to figure out the data types, operations on data, language constructs to be supported, source code syntax and all.

DataType
========
```
datatypes       operations supported                description
rank            count, compare                      
suit            count, compare
card            deal, play, count
deck            shuffle, deal
exdeck                                              # extended deck of custome size
points          add, subtract, count, compare
amount          add, subtract, bet
player
```
Sample Code
===========
This is a small hello world type game, where we deal a standard deck of card to four players. Each play alternatively till they exhaust all their card and the highest point getter wins. Points is same as rank (1-13), if there is a tie we break it with highest card suit, whoever has highest suit of King(13). The ranking of suit is say (Diamond > Heart > Spade > Club).
I am using .cg extension for card game source
```
HighCard.cg
#### This is comment
#### 
init() {
    deck d shuffle
    player p1 p2 p3 p4
}
win() {
    card count 0  # until card becomes 0
    max points
    high card king
}
cardrank() {
    rank
    king
}
rule() {
    cardrank    # only rule is cardrank
}
%%
# begin play
deal card sequence  # sequentially deal
while (card left) {
    play each player
    card count - # decrease card count
    points + # increase points for each player
    if win()
        out player    
}
```
