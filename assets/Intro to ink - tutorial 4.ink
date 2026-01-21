/* 
    First, welcome to variables.
    This programming fundamental lets use store bits of useful information.
    You have to declare variables at the top, like you see below here.
    All variables MUST have a starting value.
    The type of value determins the type of function:
    number, text, or boolean (true/false). Note that text must be contained in "" quotation marks.
*/

VAR conductor_name = "TABITHA BRIMSTONE"
VAR refused = false
VAR tried_options = 0
VAR bargained = 0
VAR searched_for = 0

<b>INK TUTORIAL PART 4: DIALOGUE TREE EXAMPLE<b><br>for IMGD/WR 3450 at WPI. Created by Prof. Ben Schneider, 2025.

This tutorial models an interactive conversation or "dialogue tree", including a main loop, side topics, and forward progression (an end state). It also shows simple use of variables and if statements.

Once again, the best way to use this is to follow on both the left and right side in Inky.

* [Continue] -> conv_start

=== conv_start ===
"Ticket, please. You <i>do</i> have your ticket?"

The woman, in her blue conductor's uniform, with its many, many brass buttons, glares down at you. The blue-brimmed hat sits atop her curly hair, behind two forward-pointing horns. 
-> loop1

== loop1_intro ===
The conductor glowers, her hand held out for your ticket. 

-> loop1

=== loop1 ===
/* 
    Here is ONE way to set up a conversation loop: 
    Each topic diverts to a knot for that topic.
    
    NEW TRICK: Use curly brackets { } to put conditions on whether a choice will show up.
    
    Remember to use + for 'sticky' choices that don't go away.
    (I could have used * for the ones that wouldn't repeat anyway, but just using + for all will result in fewer mistype errors.)
*/
+ "Ticket?"
    -> loop1_ticket
+ "Who are you?" 
    -> loop1_whoareyou
+ {searched_for == 0} [Search your pockets] -> loop1_search_pockets
+ {searched_for == 1} [Search your bag] -> loop1_search_bag
+ {searched_for == 2} [Search your wallet] -> loop1_search_wallet
* {searched_for > 0} [Make a joke] -> loop1_joke
+ "Ticket. Of course. Ticket. Let me think..." [(Advance)]
    "Best think fast," she says, and crosses her arms. There's a regular old blaze in her eyes now.
    -> ultimatum
+ "I - I think I may have lost it?"</i> [(Advance)]
    She crosses her arms. There's a regular old blaze in her eyes now.
    "If you ever had it in the first place."
    -> ultimatum

/*
    Note that the joke choice is *not* sticky, so you only get to try it once.
    The search choice could have been made non-sticky as well, but because of the conditions they don't have to be.
*/


=== loop1_ticket ===
"Yes, your ticket. Are you hard of hearing? Or <i>exceptionally</i> stupid?"
She furrows her brows...
+ [You wait...] 
- ...and continues.
"Not <i>opera</i> tickets or - or raffle tickets or tickets to the roving bestiary. <i>Train tickets.</i> For <i>this</i> train!"

+ [Continue] -> loop1_intro


=== loop1_whoareyou ===
"Who - who am <i>I</i>?"

She lifts her chin up and tugs down at her stiff blue uniform.

+ You notice small brass badge on it.[] The name emblazoned there: {conductor_name}.
- "Do you mean to be... <i>impertinent</i>? I'm a conductor. And I am <i>here</i> to collect your ticket.
+ [Um... okay then.] -> loop1_intro


=== loop1_joke ===
"Must be... around her somewhere," you say with a grin. Hoping it comes off at least a little funny.
A glance up comfirms it very much did not.

* [Oh well.] -> loop1_intro


=== loop1_search_pockets ===
You check your pockets. 
~ searched_for = searched_for + 1

She rolls her eyes.

+ [Nope, not there.] -> loop1_intro


=== loop1_search_bag ===
You root around in your bag.
You keep going even after you're sure you won't find it.
~ searched_for = searched_for + 1

She clears her throat.

+ [Not there either.] -> loop1_intro


=== loop1_search_wallet ===
You pull out your wallet and leaf through the various bills and cards. 
~ searched_for = searched_for + 1

She grimaces. Red sparks have appeared in her eyes.

+ [Also not theere.] -> loop1_intro


=== ultimatum ===
"Look," she growls. "You give me a ticket or you get off this train. Is that understood?"

-> loop2

=== loop2_intro ===
"Ticket, or I throw you off this train."
-> loop2

=== loop2 ===
/*
    Here is ANOTHER way to format this kind of conversation: put it (almost all) in one block. 
    Note that how you can nest text and other choices inside of choices by adding another + or * (so + + here).
*/
+ "Can't I buy one now?"
    "Buy one? <i>Now</i>?"
    It's like you've momentarily disarmed her. But... only momentarily.
    
    "No. You <i>cannot</i>. That is not how it works." Her eyes are ablaze. "There are rules. And we have to follow the rules. All of us. Every one. Whether we like it or not. And - and - the rules are, you are supposed to have a ticket <i>before</i> you board.
    ~ tried_options = tried_options + 1
    + + "Oh, I see then." -> loop2_intro
+ "What if I refuse?"
    "If you refuse..." she fumes through gritted teeth. "Then I will bodily lift you up and heave you off this train."
    ~ refused = true
    ~ tried_options = tried_options + 1
    You're about to ask if she'd really do that... When it strikes you that she could and positively would.
    + + "Got it." -> loop2_intro
* {bargained == 0} "There must be some way to work this out." -> loop2_bargain
* {bargained == 1} "There's no compromise or... other way...?" -> loop2_bargain
* {tried_options >= 2} [Get up and go. (Advance)] -> loop2_getup


=== loop2_bargain
/*
    THIS is a conditional or IF/THEN statement
    You can read it this way:
    IF bargained is 1 
        THEN follow the first intended text block
    ELSE (that is, otherwise): follow the second
    
    Read up in the ink manual for more conditional and logic  tricks
*/
{ bargained == 0:
    The fires in her eyes sputter dangerously.
    
    "I <i>do</i> hope you mean <i>by giving me a ticket.</i>"
    ~ bargained = bargained + 1
    + "Er, yes, I suppose!" 
    -> loop2_intro
- else:
    Her eyes are infernoes now and she bares her teeth, two sharp fangs jutting up from her lower lip.
    She doesn't even reply. She merely growls.
    ~ bargained = bargained + 1
    + [On second thought...] -> loop2_intro
}


=== loop2_getup ===
With no other options and no idea where your ticket's gone, you slowly get up from your seat.
Strangely, you realize, you're taller than the conductor. Somehow this doesn't make her any less intimidating.
You turn back and give one last glance at your seat.
* [Look]
- There, right on the cushion, in the depression made by your form... is the ticket.
"I'll take that, thanks," she says in a curt, almost cheerful voice. And, with an <i>un</i>-fiery twinkle in her eyes, snatches it up, nods to you, and moves on.
"Ticket, please," you hear her say to the next passenger. "You <i>do</i> have your ticket?"
->END
