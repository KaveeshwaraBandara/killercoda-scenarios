# One ROS 2 graph, two machines

A real robot is **two computers**: a small one on wheels (usually a Raspberry Pi) running the hardware nodes, and your laptop running teleop, visualization, and the code you're developing. ROS 2 spans both — nodes discover each other over the network, and a topic doesn't care that its publisher is on your desk and its subscriber is on the floor.

In this scenario you will:

- run **two machines** in one ROS 2 graph and watch nodes appear across the network
- use **`ROS_DOMAIN_ID`** to isolate them — and see exactly what "wrong domain ID" looks like, so you recognize the #1 bring-up bug when it bites you
- write a **motor driver** node on the "robot" that turns `/cmd_vel` into wheel speeds
- drive it with the **exact square-driving code from the simulator**, unchanged — the sim-to-real payoff

Two containers are starting in the background as your two machines. (Real hardware is real hardware — but everything *above* the motor wires works precisely like this.)

Part of the free course **[Learn ROS 2 from Zero](https://kaveeshwarabandara.github.io/ros2-course/)** — this is Stage 3, previewed without a robot.

Click **START**.
