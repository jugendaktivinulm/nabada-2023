include <components.scad>

wall_h = 1500;

module wall1r(anchor = CENTER) {
	prism_([500, 1000, wall_h], anchor = anchor, covers = FABRIC_RIGHT);
}

module wall2r(anchor = CENTER) {
	cube_([500, 2000, wall_h], anchor = anchor, covers = FABRIC_RIGHT, struts = [1, 1, 0]);
}

module wall3r(anchor = CENTER) {
	cube_([500, 1000, 0.75*wall_h - beam_width], anchor = anchor, covers = FABRIC_RIGHT);
}

module wall4r(anchor = CENTER, spin = 0, orient = TOP) {
	prism_([1000, 0.25*wall_h + beam_width, 500], spin = spin, anchor = anchor, orient = orient, covers = FABRIC_BOTTOM);
}

module wall5r(anchor = CENTER, spin = 0) {
	prism_([1000, 500, 0.75*wall_h], anchor = mirror([0, 1, 0], anchor), covers = FABRIC_RIGHT, spin = spin);
}

module wallr() {
	                                          wall5r(anchor = BOTTOM + RIGHT + FRONT, spin = 270);
	move([0, 1000, 0.75*wall_h - beam_width]) wall4r(anchor = BOTTOM + RIGHT + FRONT, spin = 270, orient = LEFT);
	move([0, 1000, 0                       ]) wall3r(anchor = BOTTOM + RIGHT + FRONT);
	move([0, 2000, 0                       ]) wall2r(anchor = BOTTOM + RIGHT + FRONT);
	move([0, 4000, 0                       ]) wall1r(anchor = BOTTOM + RIGHT + FRONT);
}

module wall1l(anchor = CENTER, spin = 0) {
	prism_([1000, 500, wall_h], anchor = anchor, covers = FABRIC_RIGHT, spin = spin);
}

module wall2l(anchor = CENTER) {
	cube_([500, 2000, wall_h], anchor = anchor, covers = FABRIC_LEFT, struts = [1, 1, 0]);
}

module wall3l(anchor = CENTER) {
	cube_([500, 1000, 0.75*wall_h - beam_width], anchor = anchor, covers = FABRIC_LEFT);
}

module wall4l(anchor = CENTER, spin = 0, orient = TOP) {
	prism_([1000, 0.25*wall_h + beam_width, 500], spin = spin, anchor = anchor, orient = orient, covers = FABRIC_TOP);
}

module wall5l(anchor = CENTER, spin = 0) {
	prism_([500, 1000, 0.75*wall_h], anchor = mirror([0, 1, 0], anchor), covers = FABRIC_RIGHT, spin = spin);
}

module walll() {
	                                          wall5l(anchor = BOTTOM + RIGHT + FRONT, spin = 180);
	move([0, 1000, 0.75*wall_h - beam_width]) wall4l(anchor = TOP + RIGHT + FRONT, spin = 270, orient = LEFT);
	move([0, 1000, 0                       ]) wall3l(anchor = BOTTOM + LEFT + FRONT);
	move([0, 2000, 0                       ]) wall2l(anchor = BOTTOM + LEFT + FRONT);
	move([0, 4000, 0                       ]) wall1l(anchor = BOTTOM + LEFT + BACK, spin = 90);
}



bridge_l  = 1500;
bridge_w  = 1500;
bridge_h1 = 1000;
bridge_h2 = 1500;

module bridge_bottom(anchor = CENTER) {
	cube_([bridge_w, bridge_l, bridge_h1], anchor = anchor, struts = [1, 1, 0]);
}

module bridge_top(anchor = CENTER) {
	cube_([bridge_w, bridge_l, bridge_h2], anchor = anchor, covers = FABRIC_FRONT + FABRIC_LEFT + FABRIC_RIGHT, struts = [1, 1, 0]);
}

module bridge_front(anchor = CENTER, orient = TOP, spin = 0) {
	prism_([500, bridge_h2, bridge_w], anchor = anchor, orient = orient, spin = spin, covers = FABRIC_RIGHT + FABRIC_TOP + FABRIC_BOTTOM);
}

module bridge() {
	bridge_bottom(anchor = BOTTOM + FRONT);
	move([0, 0, bridge_h1]) bridge_top(anchor = BOTTOM + FRONT);
	move([0, bridge_l, bridge_h1]) bridge_front(anchor = BACK + LEFT, orient = LEFT, spin = 90);

	move([0, 0, bridge_h1 + bridge_h2]) plate_xy([bridge_w + 1000, bridge_l + 750], anchor = FRONT + BOTTOM);
	beam_z(3800, anchor = BOTTOM + BACK);
}

module turret_base(anchor = BOTTOM) {
	l = 500;
	w = 500;
	h = 1400;
	cube_([w, l, h], anchor = anchor, covers = FABRIC_BACK + FABRIC_LEFT + FABRIC_RIGHT, struts = [1, 1, 0]) {
		position(CENTER) ymove(beam_width/2) beam_z(h, anchor = FRONT);
		position(TOP   ) beam_x(w - 2*beam_width, anchor = TOP   );
		position(BOTTOM) beam_x(w - 2*beam_width, anchor = BOTTOM);

		children();
	};
}



turret_top_l = 1000;
turret_top_w = 1000;
turret_top_h =  800;
turret_top_d =  300;

module turret_top1(anchor = CENTER) {
	cube_([turret_top_w, turret_top_l, turret_top_d], anchor = anchor, covers = FABRIC_BACK + FABRIC_LEFT + FABRIC_RIGHT) {
		position(BOTTOM) beam_x(turret_top_w - 2*beam_width, anchor = BOTTOM);
		position(TOP   ) beam_x(turret_top_w - 2*beam_width, anchor = TOP   );
		position(TOP   ) ymove(-beam_width/2) beam_z_(turret_top_d + 1000, anchor = TOP + RIGHT + BACK);
	}
}

module turret_top2(orient = TOP, spin = 0, anchor = CENTER) {
	prism_([turret_top_l, turret_top_h - turret_top_d, turret_top_w], orient = orient, spin = spin, anchor = anchor, covers = FABRIC_BACK + FABRIC_LEFT + FABRIC_TOP + FABRIC_BOTTOM);
}


module turret_top(anchor = BOTTOM) {
	turret_top1(anchor = BOTTOM);
	zmove(turret_top_d) turret_top2(orient = RIGHT, spin = 90, anchor = FRONT);
	move([0, - turret_top_l/2 + beam_width, turret_top_d - beam_height]) xrot(20) ymove(-500) beam_y(2200, anchor = TOP + FRONT);
}
