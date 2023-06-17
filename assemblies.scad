include <components.scad>

wall_h = 1500;

module wall1r(anchor = BOTTOM) {
	prism_([500, 1000, wall_h], anchor = anchor, covers = FABRIC_RIGHT + PLATE_TOP);
}

module wall2r(anchor = BOTTOM) {
	cube_([500, 2000, wall_h], anchor = anchor, covers = FABRIC_RIGHT + PLATE_TOP, struts = [1, 1, 0]);
}

module wall3r(anchor = BOTTOM) {
	cube_([500, 1000, 0.75*wall_h - beam_width], anchor = anchor, covers = FABRIC_RIGHT) {
		position(TOP) prism_([1000, 0.25*wall_h + beam_width, 500], spin = 270, anchor = FRONT, orient = LEFT, covers = FABRIC_BOTTOM + PLATE_RIGHT);
	}
}

module wall4r(anchor = BOTTOM) {
	mirror([0, 1, 0]) prism_([500, 1000, 0.75*wall_h], anchor = mirror([0, 1, 0], anchor), covers = FABRIC_RIGHT + PLATE_TOP);
}

module wallr() {
	            wall4r(anchor = BOTTOM + RIGHT + FRONT);
	ymove(1000) wall3r(anchor = BOTTOM + RIGHT + FRONT);
	ymove(2000) wall2r(anchor = BOTTOM + RIGHT + FRONT);
	ymove(4000) wall1r(anchor = BOTTOM + RIGHT + FRONT);
}

module wall1l(anchor = BOTTOM) { mirror([1, 0, 0]) wall1r(mirror([1, 0, 0], anchor)); }
module wall2l(anchor = BOTTOM) { mirror([1, 0, 0]) wall2r(mirror([1, 0, 0], anchor)); }
module wall3l(anchor = BOTTOM) { mirror([1, 0, 0]) wall3r(mirror([1, 0, 0], anchor)); }
module wall4l(anchor = BOTTOM) { mirror([1, 0, 0]) wall4r(mirror([1, 0, 0], anchor)); }
module walll() { mirror([1, 0, 0]) wallr(); }

module bridge() {
	l  = 1500;
	w  = 1500;
	h1 = 1000;
	h2 = 1500;

	cube_([w, l, h1], anchor = BOTTOM + FRONT, struts = [1, 1, 0]) {
		position(TOP) cube_([w, l, h2], anchor = BOTTOM, covers = FABRIC_FRONT + FABRIC_LEFT + FABRIC_RIGHT, struts = [1, 1, 0]) {
			position(BACK) prism_([500, h2, w], anchor = LEFT, orient = LEFT, spin = 90, covers = FABRIC_RIGHT + FABRIC_TOP + FABRIC_BOTTOM);
			position(TOP + FRONT) plate_xy([w + 1000, l + 750], anchor = FRONT + BOTTOM);
		}
		position(FRONT + BOTTOM) beam_z(3800, anchor = BOTTOM + BACK);
	}
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

module turret_top(anchor = BOTTOM) {
	l = 1000;
	w = 1000;
	h = 800;
	d = 300;

	cube_([w, l, d], anchor = anchor, covers = FABRIC_BACK + FABRIC_LEFT + FABRIC_RIGHT) {
		position(TOP) prism_([l, h - d, w], orient = RIGHT, spin = 90, anchor = FRONT, covers = FABRIC_BACK + FABRIC_LEFT + FABRIC_TOP + FABRIC_BOTTOM);
		position(TOP + FRONT) move([0, beam_width, -beam_height]) xrot(20) ymove(-500) beam_y(2200, anchor = TOP + FRONT);
		position(BOTTOM) beam_x(w - 2*beam_width, anchor = BOTTOM);
		position(TOP   ) beam_x(w - 2*beam_width, anchor = TOP   );
		position(TOP   ) ymove(-beam_width/2) beam_z(d + 1000, anchor = TOP + RIGHT, spin = 90);
	}
}
