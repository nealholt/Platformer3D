
Originally created by following this tutorial
Godot 4 Beginners: Learn to make a 3D Platformer!
by BornCG
https://www.youtube.com/playlist?list=PLda3VoSoc_TTp8Ng3C57spnNkOw3Hm_35
extended by Neal Holtschulte

Available on github:
https://github.com/nealholt/Platformer3D

Playable on itch.io:
https://nealholt.itch.io/3d-platformer

https://www.reddit.com/r/godot/comments/1xip5zh/i_completed_and_extended_borncgs_platformer_3d/

=== Puzzle platformer:
	Fastest time to pick up X number of coins
	Choose route to different upgrades, branching path of upgrades, but chosen by moving in the world

=== KNOWN BUGS
These problems only appear in the browser version playable on itch.io:
 * loading screen shows 0% then 100% with nothing in between
 * lag spike on initial particle effect (first time you sprint)
 * level 3 periodically crashes the whole browser tab in firefox and duck duck go browsers, but not in edge

=== MISC IDEAS NOT YET IMPLEMENTED
-Upgrades:
  -ground pound (rapid descend, possibly dealing damage to nearby enemies)
  -slow fall (combine with "move while airborn" to fall through coins in the air)
-copy reusable level segments into their own scenes
-Add in occasional wave animation (the animation is already implemented), maybe only when facing the camera, maybe on a button
-Tumbling blocks or rolling balls falling down a ramp to block your path
-a block thrower that impedes the player
