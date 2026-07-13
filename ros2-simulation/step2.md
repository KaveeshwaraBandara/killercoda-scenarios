# Give it physics and a motor

Your URDF is a **costume**: shapes and colors. A physics engine needs three more things:

- **collision** geometry — the shape used for "what happens when this touches that"
- **inertial** properties — mass and how it's distributed. No mass, nothing for physics to push on.
- **friction** — wheels must grip; the caster must slide

And one more, the conceptual leap: URDF says what the body **is**, but nothing about what makes the wheels **turn**. In Gazebo, behavior comes from a **plugin** — code that runs inside the simulator. `DiffDrive` is a simulated motor controller: it listens for velocity commands and torques the wheel joints.

Write the physics-ready version:

```bash
cat > /work/my_bot_sim.urdf <<'EOF'
<?xml version="1.0"?>
<robot name="my_bot">

  <link name="base_link">
    <visual>
      <geometry><box size="0.4 0.3 0.1"/></geometry>
      <material name="blue"><color rgba="0.2 0.4 0.9 1.0"/></material>
    </visual>
    <collision><geometry><box size="0.4 0.3 0.1"/></geometry></collision>
    <inertial>
      <mass value="4.0"/>   <!-- kg -->
      <inertia ixx="0.033" ixy="0" ixz="0" iyy="0.056" iyz="0" izz="0.083"/>
    </inertial>
  </link>

  <link name="left_wheel">
    <visual>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </visual>
    <collision>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </collision>
    <inertial>
      <mass value="0.3"/>
      <inertia ixx="0.0006" ixy="0" ixz="0" iyy="0.0006" iyz="0" izz="0.001"/>
    </inertial>
  </link>
  <joint name="left_wheel_joint" type="continuous">
    <parent link="base_link"/><child link="left_wheel"/>
    <origin xyz="0 0.17 -0.03"/><axis xyz="0 1 0"/>
  </joint>

  <link name="right_wheel">
    <visual>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </visual>
    <collision>
      <geometry><cylinder radius="0.08" length="0.04"/></geometry>
      <origin rpy="1.5708 0 0"/>
    </collision>
    <inertial>
      <mass value="0.3"/>
      <inertia ixx="0.0006" ixy="0" ixz="0" iyy="0.0006" iyz="0" izz="0.001"/>
    </inertial>
  </link>
  <joint name="right_wheel_joint" type="continuous">
    <parent link="base_link"/><child link="right_wheel"/>
    <origin xyz="0 -0.17 -0.03"/><axis xyz="0 1 0"/>
  </joint>

  <link name="caster">
    <visual><geometry><sphere radius="0.05"/></geometry></visual>
    <collision><geometry><sphere radius="0.05"/></geometry></collision>
    <inertial>
      <mass value="0.2"/>
      <inertia ixx="0.0002" ixy="0" ixz="0" iyy="0.0002" iyz="0" izz="0.0002"/>
    </inertial>
  </link>
  <joint name="caster_joint" type="fixed">
    <parent link="base_link"/><child link="caster"/>
    <origin xyz="0.15 0 -0.06"/>
  </joint>

  <!-- The caster must SLIDE (near-zero friction) while the wheels GRIP. -->
  <gazebo reference="caster">
    <mu1>0.01</mu1>
    <mu2>0.01</mu2>
  </gazebo>

  <!-- The simulated motor controller. It converts a requested robot velocity
       into wheel torques — which is why it needs the robot's geometry. -->
  <gazebo>
    <plugin filename="gz-sim-diff-drive-system" name="gz::sim::systems::DiffDrive">
      <left_joint>left_wheel_joint</left_joint>
      <right_joint>right_wheel_joint</right_joint>
      <wheel_separation>0.34</wheel_separation>  <!-- matches the URDF! -->
      <wheel_radius>0.08</wheel_radius>
      <topic>cmd_vel</topic>       <!-- it listens here -->
      <odom_topic>odom</odom_topic><!-- it reports its position here -->
    </plugin>
  </gazebo>

</robot>
EOF
echo "robot is now physical"
```{{exec}}

!!! warning "Where do inertia numbers come from?"
    Formulas — every basic shape has one (search "list of moments of inertia"). What matters practically: **wildly wrong inertia makes simulations explode.** Robots that vibrate, spin, or launch into the sky on spawn are almost always an inertia bug. If you see that, check here first.

Note the plugin needs `wheel_separation` and `wheel_radius` that **match the URDF geometry** — 0.17 m either side of center = 0.34 m apart. Lie to it here and your robot will consistently under- or over-turn. (That's a preview of Stage 3's real calibration problem, in miniature.)
