# Build a robot and drive it

You're going to build a robot from an empty file and drive it around a physics-simulated world — in your browser, without a GPU.

In this scenario you will:

- **describe** a two-wheeled robot in URDF: links, joints, a kinematic tree
- give it **physics** — mass, collision shapes, friction — and a differential-drive **motor plugin**
- **spawn** it into a Gazebo world and **bridge** it into the ROS 2 graph
- **drive** it: first by hand, then with a node of your own that drives a square
- watch `/odom` to see **where the robot actually went** versus where you told it to go

!!! note "Headless simulation"
    Gazebo normally shows a 3D window. This machine has no display, so we run the **physics server only** and observe the robot through its `/odom` topic — exactly how you'd debug a robot over SSH. The physics is completely real; you're reading it as numbers instead of pixels. (Run [Stage 2 of the course](https://kaveeshwarabandara.github.io/ros2-course/stage-2-simulation/) on your own machine to *watch* it.)

Gazebo Harmonic is installing in the background — it's a big one, so it may still be working when you hit Step 1. There's a wait command there.

Part of the free course **[Learn ROS 2 from Zero](https://kaveeshwarabandara.github.io/ros2-course/)**.

Click **START**.
