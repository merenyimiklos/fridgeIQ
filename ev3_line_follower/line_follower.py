#!/usr/bin/env python3
"""
EV3 3-Sensor Line Follower  –  competition-quality, production-ready
======================================================================
Hardware
--------
  Color sensor LEFT   : port 1  (ev3dev InputPort.P1)
  Color sensor MIDDLE : port 2  (ev3dev InputPort.P2)
  Color sensor RIGHT  : port 3  (ev3dev InputPort.P3)
  Drive motor LEFT    : port C  (ev3dev OutputPort.C)
  Drive motor RIGHT   : port B  (ev3dev OutputPort.B)

Control strategy
----------------
  1. The three sensors are read as reflected-light intensity (0-100).
  2. Raw readings are normalised to a 0-1 scale using calibrated
     BLACK / WHITE constants, then clamped.
  3. The MIDDLE sensor produces the primary error signal:
       error = 0.5 - norm_middle
       (0.5 means middle sensor is on the line edge, which is the
        setpoint; positive error → drifted right → steer left)
  4. A standard PD term drives the motors:
       correction = Kp * error + Kd * (error - prev_error)
  5. The LEFT and RIGHT sensors act as guard rails:
       - If the left  sensor sees black →  strong left  correction boost
       - If the right sensor sees black →  strong right correction boost
  6. Lost-line recovery:
       - If ALL three sensors see white, the robot pivots slowly in the
         direction of the last known error until any sensor re-acquires
         the line.

Tuning cheat-sheet (also in README.md)
---------------------------------------
  Zig-zags / oscillation  → decrease Kp or increase Kd
  Too slow               → increase BASE_SPEED
  Loses line often        → increase SIDE_BOOST, decrease LOST_SPEED
"""

# ---------------------------------------------------------------------------
# Standard library & ev3dev2 imports
# ---------------------------------------------------------------------------
from ev3dev2.motor import LargeMotor, OUTPUT_B, OUTPUT_C, SpeedPercent
from ev3dev2.sensor import INPUT_1, INPUT_2, INPUT_3
from ev3dev2.sensor.lego import ColorSensor
from ev3dev2.button import Button
import time

# ---------------------------------------------------------------------------
# ── CALIBRATION CONSTANTS  (tune these for your specific mat / lighting) ──
# ---------------------------------------------------------------------------
BLACK_VALUE = 10   # Reflected light reading on solid black  (0-100)
WHITE_VALUE = 85   # Reflected light reading on solid white  (0-100)

# ---------------------------------------------------------------------------
# ── SPEED / CONTROLLER PARAMETERS  (tune these for your robot) ──────────
# ---------------------------------------------------------------------------
BASE_SPEED   = 40   # Nominal forward speed (% of max motor speed)
Kp           = 55   # Proportional gain  – bigger → faster response, may oscillate
Kd           = 8    # Derivative  gain   – bigger → dampens oscillation
SIDE_BOOST   = 30   # Extra correction added when a side sensor is on the line
LOST_SPEED   = 20   # Pivot speed during lost-line recovery (slower = more reliable)
LOOP_DELAY   = 0.01 # Seconds between control loop iterations (10 ms)


# ---------------------------------------------------------------------------
# Helper: normalise a raw sensor reading to [0.0 – 1.0]
#   0.0  ≈ pure black
#   1.0  ≈ pure white
# ---------------------------------------------------------------------------
def normalise(raw: int) -> float:
    """Return sensor reading on a 0 (black) to 1 (white) scale."""
    span = WHITE_VALUE - BLACK_VALUE
    if span == 0:
        return 0.5  # Avoid division by zero if miscalibrated
    normalised = (raw - BLACK_VALUE) / span
    return max(0.0, min(1.0, normalised))   # Clamp to [0, 1]


def on_line(norm_value: float, threshold: float = 0.5) -> bool:
    """Return True when the sensor reading is below the threshold (darker side)."""
    return norm_value < threshold


# ---------------------------------------------------------------------------
# Initialise hardware
# ---------------------------------------------------------------------------
sensor_left   = ColorSensor(INPUT_1)
sensor_middle = ColorSensor(INPUT_2)
sensor_right  = ColorSensor(INPUT_3)

motor_left  = LargeMotor(OUTPUT_C)
motor_right = LargeMotor(OUTPUT_B)

# Put all sensors in reflected-light mode
sensor_left.mode   = ColorSensor.MODE_COL_REFLECT
sensor_middle.mode = ColorSensor.MODE_COL_REFLECT
sensor_right.mode  = ColorSensor.MODE_COL_REFLECT

btn = Button()

# ---------------------------------------------------------------------------
# Main control loop
# ---------------------------------------------------------------------------
prev_error    = 0.0   # Previous error for derivative term
last_error    = 0.0   # Remembers last known error direction for recovery pivoting

print("EV3 Line Follower ready.  Press any button to START.")
btn.wait_for_bump()
print("Running!  Press any button to STOP.")

while not btn.any():

    # ── 1. Read sensors ────────────────────────────────────────────────────
    left_raw   = sensor_left.reflected_light_intensity
    middle_raw = sensor_middle.reflected_light_intensity
    right_raw  = sensor_right.reflected_light_intensity

    # ── 2. Normalise readings ──────────────────────────────────────────────
    left_n   = normalise(left_raw)
    middle_n = normalise(middle_raw)
    right_n  = normalise(right_raw)

    # ── 3. Detect lost-line condition (all sensors see white) ──────────────
    all_white = (not on_line(left_n)
                 and not on_line(middle_n)
                 and not on_line(right_n))

    if all_white:
        # ── 3a. Recovery: pivot toward last known error direction ──────────
        # last_error > 0 means the robot was drifting right → pivot left
        # last_error < 0 means the robot was drifting left  → pivot right
        if last_error >= 0:
            # Line was last seen on the left – spin left to search
            motor_left.run_forever(speed_sp=SpeedPercent(-LOST_SPEED))
            motor_right.run_forever(speed_sp=SpeedPercent(LOST_SPEED))
        else:
            # Line was last seen on the right – spin right to search
            motor_left.run_forever(speed_sp=SpeedPercent(LOST_SPEED))
            motor_right.run_forever(speed_sp=SpeedPercent(-LOST_SPEED))

        time.sleep(LOOP_DELAY)
        continue   # Skip the rest of the loop until we re-acquire the line

    # ── 4. Primary error from the MIDDLE sensor ────────────────────────────
    # Setpoint: 0.5  (middle sensor sits on the black-white edge)
    # error > 0  → sensor reads too white → robot drifted RIGHT → correct LEFT
    # error < 0  → sensor reads too black → robot drifted LEFT  → correct RIGHT
    error = 0.5 - middle_n

    # ── 5. Derivative term ────────────────────────────────────────────────
    d_error = error - prev_error

    # ── 6. PD correction ──────────────────────────────────────────────────
    correction = Kp * error + Kd * d_error

    # ── 7. Side-sensor guard-rail boost ───────────────────────────────────
    # If the left sensor is on the line the robot has drifted too far right:
    #   add a leftward correction boost.
    # If the right sensor is on the line the robot has drifted too far left:
    #   add a rightward correction boost.
    if on_line(left_n):
        correction += SIDE_BOOST      # Steer more left (positive = steer left)
    if on_line(right_n):
        correction -= SIDE_BOOST      # Steer more right

    # ── 8. Apply correction to motors ─────────────────────────────────────
    # correction > 0 → steer left  → slow down right motor, speed up left
    # correction < 0 → steer right → slow down left  motor, speed up right
    left_speed  = BASE_SPEED - correction
    right_speed = BASE_SPEED + correction

    # Clamp motor speeds so they stay in [-100, 100]
    left_speed  = max(-100, min(100, left_speed))
    right_speed = max(-100, min(100, right_speed))

    motor_left.run_forever(speed_sp=SpeedPercent(left_speed))
    motor_right.run_forever(speed_sp=SpeedPercent(right_speed))

    # ── 9. Update state for next iteration ────────────────────────────────
    prev_error = error
    last_error = error   # Remember the last non-lost-line error direction

    time.sleep(LOOP_DELAY)

# ---------------------------------------------------------------------------
# Clean stop
# ---------------------------------------------------------------------------
motor_left.stop()
motor_right.stop()
print("Stopped.")
