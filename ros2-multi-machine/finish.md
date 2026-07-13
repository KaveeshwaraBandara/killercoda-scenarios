# You've built the software half of a real robot

In this session you:

- ran **one ROS 2 graph across two machines** — with zero network configuration
- diagnosed the **`ROS_DOMAIN_ID`** trap that eats beginners' bring-up days
- wrote a **motor driver** that converts `/cmd_vel` into differential-drive wheel speeds
- drove it with **simulator code, unmodified** — the sim-to-real promise, delivered
- saw why a node must **stop the robot when it dies**

What's left for real hardware is genuinely just hardware: a Pi, a motor board, a battery, and the physics of a floor that slips. The software architecture you just exercised is exactly the one that runs on it.

Nothing to clean up — both machines destroy themselves when this session ends.

## Keep going

This previews **Stage 3** of the free course **[Learn ROS 2 from Zero](https://kaveeshwarabandara.github.io/ros2-course/)**:

- 🤖 **[Stage 3 — Real Hardware](https://kaveeshwarabandara.github.io/ros2-course/stage-3-real-hardware/)** — choose a platform, bring it up, measure the reality gap, and build a patrol robot
- 🌍 **[Stage 2 — Simulation](https://kaveeshwarabandara.github.io/ros2-course/stage-2-simulation/)** — where `square_driver.py` came from, if you skipped ahead
