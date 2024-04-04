d = 160;
$fn = 100;

h = 200;
hull() {
	difference() {
		sphere(d/2);
		translate([-d, -d, -2*d]) cube([2*d, 2*d, 2*d]);
	}
	translate([0, d/2 - 1, h]) sphere(2, $fn = 10);
}
