// ALL VALUES IN MM
WIRE_THICKNESS = 3;


$fn = 100;
PLATE_THICKENESS = 1;
FITTING_ROOM = 0.3;
MIDDLE_DIAMETER = 40;
OUTER_SIZE = 70;
CORNER_R = 10;

module down(z) {
  translate([0, 0, -z]) children();
}
module up(z) {
  translate([0, 0, z]) children();
}
module right(x) {
  translate([x, 0, 0]) children();
}

module left(x) {
  translate([-x, 0, 0]) children();
}
module right(x) {
  translate([x, 0, 0]) children();
}

module front(y) {
  translate([0, -y, 0]) children();
}
module back(y) {
  translate([0, y, 0]) children();
}

module rotateZ(deg) {
  rotate(deg, [0, 0, 1]) children();
}

module yin(middle_diameter, wire_thickness) {
  INNER_CIRCLE_R = (middle_diameter - wire_thickness) / 4 - wire_thickness / 2;
  OUTER_CIRCLE_R = (middle_diameter - wire_thickness) / 4 + wire_thickness / 2;

  right (wire_thickness / 2) {
    difference() {
      intersection() {
        circle((middle_diameter - wire_thickness) / 2);
        front((middle_diameter - wire_thickness) / 2) square((middle_diameter - wire_thickness), center=true);
      }
      right(OUTER_CIRCLE_R - wire_thickness) circle(OUTER_CIRCLE_R);
    }
    left(INNER_CIRCLE_R + wire_thickness) circle(INNER_CIRCLE_R);
  }
}


module fitting_hollow_yinyang() {
  module base() offset(-PLATE_THICKENESS - FITTING_ROOM) yinyang();
  mirror([1, 0, 0])
  difference() {
    base();
    offset(-PLATE_THICKENESS) base();
  }
}

module yinyang() {
  yin(MIDDLE_DIAMETER, WIRE_THICKNESS);
  rotateZ(180) yin(MIDDLE_DIAMETER, WIRE_THICKNESS);
}

module plate() {
  difference() {
    minkowski() {
      square(OUTER_SIZE - CORNER_R * 4, center=true);
      circle(CORNER_R);
    }
  }
}

difference() {
  union() {
    //linear_extrude(PLATE_THICKENESS) plate();
    color("green") linear_extrude(PLATE_THICKENESS + WIRE_THICKNESS) yinyang();
    //color("blue") linear_extrude(PLATE_THICKENESS + WIRE_THICKNESS) fitting_hollow_yinyang();
    cylinder(r1=MIDDLE_DIAMETER / 2, r2=MIDDLE_DIAMETER / 2 + PLATE_THICKENESS / 2, h=PLATE_THICKENESS / 2);
    up(PLATE_THICKENESS / 2) cylinder(r2=MIDDLE_DIAMETER / 2, r1=MIDDLE_DIAMETER / 2 + PLATE_THICKENESS / 2, h=PLATE_THICKENESS / 2);
  };
  down(1) linear_extrude(PLATE_THICKENESS + WIRE_THICKNESS + 2) offset(-PLATE_THICKENESS) yinyang();
};

difference() {
linear_extrude(PLATE_THICKENESS) plate();
union() {
    cylinder(r1=MIDDLE_DIAMETER / 2 + FITTING_ROOM, r2=MIDDLE_DIAMETER / 2 + FITTING_ROOM + PLATE_THICKENESS / 2, h=PLATE_THICKENESS / 2);
    up(PLATE_THICKENESS / 2) cylinder(r2=MIDDLE_DIAMETER / 2 + FITTING_ROOM, r1=MIDDLE_DIAMETER / 2 + FITTING_ROOM + PLATE_THICKENESS / 2, h=PLATE_THICKENESS / 2);
    down(1) cylinder(r=MIDDLE_DIAMETER / 2 + FITTING_ROOM, h=PLATE_THICKENESS + 2);
}

}
