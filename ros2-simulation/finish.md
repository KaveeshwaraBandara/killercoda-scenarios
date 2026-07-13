# You built a robot and drove it

From an empty file, in one session, you:

- **described** a differential-drive robot in URDF — links, joints, a kinematic tree
- gave it **physics**: collision shapes, mass, inertia, friction, and a DiffDrive plugin
- **spawned** it into a Gazebo world and **bridged** the simulator into the ROS 2 graph
- **drove** it by hand, then with your own square-driving node
- measured the **reality gap** — the drift between commanded and achieved motion

The best part: `square_driver.py` publishes `Twist` to `/cmd_vel` and knows nothing about Gazebo. Point it at a **real robot's** motor driver and it works unchanged. That's not a lucky accident — it's the entire reason ROS 2 is built around topics.

Nothing to clean up — this machine destroys itself when your session ends.

## Keep going

This compresses **Stage 2** of the free course **[Learn ROS 2 from Zero](https://kaveeshwarabandara.github.io/ros2-course/)**, where you do it with the **3D window open** (watching your robot fall, roll, and turn is worth the local install):

- 🌍 **[Stage 2 — Simulation](https://kaveeshwarabandara.github.io/ros2-course/stage-2-simulation/)** — the full version, with RViz and the Gazebo GUI
- 🤖 **[Stage 3 — Real Hardware](https://kaveeshwarabandara.github.io/ros2-course/stage-3-real-hardware/)** — same code, physical robot
