d = 165;
$fn = 100;

d1 = d/2;
d2 = d1 - 20;
h = d/2;

difference() {
	sphere(d/2);
	translate([-d, -d, -2*d]) cube([2*d, 2*d, 2*d]);
	sphere((d - 2)/2);
	cylinder(d = d2, h = d/2 + 1);
}
difference() {
	cylinder(d = d1, h = h);
	sphere((d - 2)/2);
	cylinder(d = d2, h = d/2 + 1);
}
