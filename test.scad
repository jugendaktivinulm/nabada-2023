include <components.scad>
include <waende.scad>

cube([4000, 5000, 1], anchor = FRONT + TOP + LEFT) {
	move([-1000, 0, 1000]) prism_([1000, 1000, 1000], covers = PLATE_ALL - PLATE_BOTTOM, anchor = BOTTOM);
	move([ 1000, 0, 1000]) cube_ ([1000, 1000, 1000], covers = PLATE_ALL - PLATE_BOTTOM, anchor = BOTTOM);
}
