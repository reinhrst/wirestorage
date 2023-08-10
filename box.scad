include <BOSL2/std.scad>
// ALL VALUES IN MM
WIRE_THICKNESS = 4;


$fn = 72;
PLATE_THICKNESS = 2;
MINIMAL_INNER_EXTRA_THICKNESS = .5;
WALL_THICKNESS = .7;
STRUT_WIDTH = 1;
WIRE_GRABBER_DELTA = .2;
SPACE_BETWEEN_STRUTS = 10;
STRUT_CORNER_R = .2;
FITTING_ROOM = 0.2;
MIDDLE_R = 20;
OUTER_SIZE = 120;
CORNER_R = 10;
CUTOUT_R = 55;
ROTATOR_WIDTH = 5;
EXTRA_SPACE_BETWEEN_PLATES = .3;

SNAIL_HOUSE_ROTATION = 100;

INSIDE_THICKNESS = PLATE_THICKNESS;

module strut(thickness) {
up(thickness / 2) back(OUTER_SIZE * 1.5 / 2) xrot(90) linear_extrude(OUTER_SIZE * 1.5) minkowski() {
      square([STRUT_WIDTH - STRUT_CORNER_R * 2, thickness - STRUT_CORNER_R * 2], center=true);
      circle(STRUT_CORNER_R, $fn=10);
    }
}

module struts(thickness) {
  nr_iterations = ceil(OUTER_SIZE * 1.5 / 2 / SPACE_BETWEEN_STRUTS) * 2;
  intersection() {
  zrot(45)
  for (rot = [0, 90]) {
    zrot(rot) {
      for (i=[-nr_iterations / 2: nr_iterations / 2]) {
        left(i * SPACE_BETWEEN_STRUTS) strut(thickness);
      }
    }
  }
  linear_extrude(thickness) square(OUTER_SIZE, center=true);
  }
}

module plate(thickness) {
  module base() {
    minkowski() {
      square(OUTER_SIZE - CORNER_R * 2, center=true);
      circle(CORNER_R);
    }
  }
  module cutout() {
    circle(CUTOUT_R + FITTING_ROOM);
  }
  intersection() {
    linear_extrude(thickness) difference() {base(); cutout();}
    struts(thickness);
  }
  linear_extrude(thickness) difference() {
    base();
    offset(- 2 * STRUT_WIDTH) base();
  }
  points = turtle([
    "xymove", [-PLATE_THICKNESS / 2, PLATE_THICKNESS / 2],
    "xmove", FITTING_ROOM * (1 - sqrt(2)),
    "yjump", thickness / 2,
    "xmove", PLATE_THICKNESS / 2 + STRUT_WIDTH,
    "yjump", 0,
  ], state=[CUTOUT_R + FITTING_ROOM * sqrt(2), 0]);
  up(thickness / 2) rotate_extrude() union() {polygon(points); yscale(-1) polygon(points);}
}

module inside(thickness, cutout_offset) {
  intersection() {
    linear_extrude(thickness) difference() {circle(CUTOUT_R - PLATE_THICKNESS / 2); offset(cutout_offset) inside_snail_house();};
    struts(thickness);
  }
  points = turtle([
    "xymove", [-PLATE_THICKNESS / 2, PLATE_THICKNESS / 2],
    "yjump", thickness / 2,
    "xmove", -STRUT_WIDTH,
    "yjump", 0,
  ], state=[CUTOUT_R, 0]);
  up(thickness / 2) rotate_extrude() union() {polygon(points); yscale(-1) polygon(points);}
}

module snail_house() {
  ROUNDOFF_R = WIRE_THICKNESS - WALL_THICKNESS * 0.8;
  rgn = difference(
      [scale(WIRE_THICKNESS + 2 * WALL_THICKNESS,  back(-.5, square([1, 10], anchor=FRONT)))],
      union([
        circle(d=WIRE_THICKNESS),
        front_half(square([WIRE_THICKNESS - WIRE_GRABBER_DELTA, WIRE_THICKNESS + 2 * WALL_THICKNESS + 1], center=true))
      ])
      );

  tforms = [
    for (a=[0:5:10]) yrot(a) * right(MIDDLE_R + WIRE_THICKNESS / 2 + WALL_THICKNESS - STRUT_WIDTH - (a-55)/360 * (WIRE_THICKNESS + WALL_THICKNESS)),
    for (a=[10:5:55]) fwd((a-10)/45 * (WIRE_THICKNESS + WALL_THICKNESS)) * yrot(a) * right(MIDDLE_R + WIRE_THICKNESS / 2 + WALL_THICKNESS - STRUT_WIDTH - (a-55)/360 * (WIRE_THICKNESS + WALL_THICKNESS)),
  ];
  render(10) intersection() {
      up(INSIDE_THICKNESS - WALL_THICKNESS) zrot(-55) cuboid([OUTER_SIZE, OUTER_SIZE, 2 * WIRE_THICKNESS + WALL_THICKNESS], anchor=BOTTOM + LEFT + FRONT, rounding=ROUNDOFF_R, edges=[TOP+FRONT]);
    up(WIRE_THICKNESS / 2 + INSIDE_THICKNESS)  xrot(-90) sweep(rgn, tforms, closed=false, caps=true);
  };
}

module top_snail_house() {
  rgn = difference(union([
        scale(WIRE_THICKNESS + 2 * WALL_THICKNESS + 2 * FITTING_ROOM,  back(-.5, square([1, 10], anchor=FRONT))),
        circle(d=WIRE_THICKNESS),
      ]),
      [square([WIRE_THICKNESS - WIRE_GRABBER_DELTA, (WIRE_THICKNESS + 2 * WALL_THICKNESS + 1 / 2)], anchor=FRONT)]);

  tforms = [
    for (a=[0:5:10]) yrot(a) * right(MIDDLE_R + WIRE_THICKNESS / 2 + WALL_THICKNESS - STRUT_WIDTH - (a-55)/360 * (WIRE_THICKNESS + WALL_THICKNESS)),
      for (a=[10:5:55]) fwd((a-10)/45 * (WIRE_THICKNESS + WALL_THICKNESS)) * yrot(a) * right(MIDDLE_R + WIRE_THICKNESS / 2 + WALL_THICKNESS - STRUT_WIDTH - (a-55)/360 * (WIRE_THICKNESS + WALL_THICKNESS)),
  ];
    up(WIRE_THICKNESS / 2 + INSIDE_THICKNESS)  xrot(-90) sweep(rgn, tforms, closed=false, caps=true);
}

module snail_house2() {
  rgn2 = [square([WALL_THICKNESS, WIRE_THICKNESS + WALL_THICKNESS + INSIDE_THICKNESS], anchor=BACK)];
  tforms2 = [
    for (a=[0:5:415]) yrot(a) * right(MIDDLE_R - STRUT_WIDTH + .5 * WALL_THICKNESS - (a-415)/360 * (WIRE_THICKNESS + WALL_THICKNESS)),
  ];

  xrot(-90) sweep(rgn2, tforms2, closed=false, caps=true);
}

module inside_snail_house() {
  radial_points  = [
    for (a=[0:5:360]) [a, MIDDLE_R - STRUT_WIDTH + .5 * WALL_THICKNESS - (a-355)/360 * (WIRE_THICKNESS + WALL_THICKNESS)]
  ];
  points = [
    for (p=radial_points) [cos(p[0]) * p[1], -sin(p[0]) * p[1]]
  ];
  zrot(SNAIL_HOUSE_ROTATION - 55) polygon(points);
}

module rotator() {
  module half(r) {
    intersection() {
      square(OUTER_SIZE, anchor=FRONT);
      difference() {
        offset(ROTATOR_WIDTH / 2) circle(r, anchor=RIGHT);
        offset(-ROTATOR_WIDTH / 2)  circle(r, anchor=RIGHT);
      }
    }
  }
  rot(45) linear_extrude(INSIDE_THICKNESS) intersection() {
    offset(STRUT_WIDTH) inside_snail_house();
    zrot(SNAIL_HOUSE_ROTATION) union() {
      half(MIDDLE_R);
      zrot(180) half(MIDDLE_R);
    }
  }
}


module bottom() {
    plate(PLATE_THICKNESS);
    inside(INSIDE_THICKNESS, 0);
    zrot(SNAIL_HOUSE_ROTATION) {snail_house(); snail_house2();};
    rotator();
}

module top() {
  difference() {
    union() {
      difference() {
        up(PLATE_THICKNESS + WIRE_THICKNESS + EXTRA_SPACE_BETWEEN_PLATES) {
          inside(PLATE_THICKNESS + WIRE_THICKNESS, -WALL_THICKNESS - FITTING_ROOM);
          plate(PLATE_THICKNESS + WIRE_THICKNESS);
        };
        zrot(SNAIL_HOUSE_ROTATION) top_snail_house();
      }
      up(PLATE_THICKNESS) {
        linear_extrude(PLATE_THICKNESS + 2 * WIRE_THICKNESS + EXTRA_SPACE_BETWEEN_PLATES) difference() {
          offset(-FITTING_ROOM) inside_snail_house();
          offset(-WALL_THICKNESS - FITTING_ROOM) inside_snail_house();
        };
      }
    }
    linear_extrude(PLATE_THICKNESS + WIRE_THICKNESS * 2 + EXTRA_SPACE_BETWEEN_PLATES) zrot(SNAIL_HOUSE_ROTATION - 55) right(MIDDLE_R) square(5, center=true);
  }
}


difference() {
  union() {
    bottom();
 //   top();
  };
 //cube(OUTER_SIZE, anchor=RIGHT);
}
