Lua Inverse Kinematics (LIK)
============================

This is a library designed to do simple inverse kinematics in pure Lua. The used algorithm is based on [FABRIK](http://www.andreasaristidou.com/FABRIK.html).

There are sample files included which can be run with the [LÖVE engine](https://love2d.org/) (see "Samples" section below).

Features:
---------

- 3D or 2D inverse kinematics (TODO: More testing on 3D chains)
- Hinge joints
- Smooth motion due to the FABRIK algorithm
- If target point cannot be reached, LIK can either reset the chain or try to find the closest possible solution (i.e. reaching for target)

Limitations:
-----------

Currently _not_ supported are:

- Multiple end effectors
- Bone offsets (i.e. currently the base of every bone is connected to the end of its parent)

*Note:* The solution of the algorithm may not be perfect, and there is no guarantee for correctness. This library should be sufficient for writing games, but probably shouldn't be used to steer a real-life robot.

Samples:
--------
Samples were written for the LÖVE 2D engine (tested with version 11.3). To run them, install LÖVE, then navigate to a sample in the samples directory and run it:

```Bash
cd samples/simplechain
love .
```

TODO:
-----

- Speed improvements!
- Write 3D sample


