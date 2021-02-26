include <helper.scad>

tubeSide=100;
tubeThick=5;

tH = 700;

bW = 550;
bD = 450;
bH = 250;
bT = tubeThick;
bOffset = 100;

module trap(w1,d,w2,h) {
	wO = (w2 - w1) / 2;

	// counter clockwise
	aT = [0,0,h];
	aB = [0,0,0];
	bT = [w1,0,h];
	bB = [w1,0,0];
	cT = [w1 + wO,d,h];
	cB = [w1 + wO,d,0];
	dT = [-wO,d,h];
	dB = [-wO,d,0];

	a = [0,0];
	b = [w1,0];
	c = [w1 + wO,d];
	d = [-wO,d];

	//     0   1   2   3   4   5   6   7
	ps = [aT, aB, bT, bB, cT, cB, dT, dB];
	fs = 
		[ [ 1, 2, 3, 0]
		, [ 2, 4, 5, 3]
		, [ 4, 6, 7, 5]
		, [ 6, 0, 1, 7]
		, [ 6, 4, 2, 0]
		, [ 5, 7, 1, 3]
		];
	//polyhedron(points = ps, faces= fs);
	linear_extrude(height = h) {
		polygon(points = [d, c, b, a]);
	}
}

module box() {
	difference() {
		union() {
			cube([bW, bD, bH]);
			translate([0,-tubeThick,0]) {
				cube([bW, tubeThick, 50]);
			}
		}
		translate([bT,-0.1,-0.1]) {
			cube([bW - bT * 2, bD - bT + 0.1, bH + 0.2]);
		}
	}
}

module raiser() {
	dT = (bD - tubeSide) / 2 - tubeThick/2;
	d = sqrt(pow(dT, 2) + pow(bOffset, 2));
	translate([tubeSide, tubeSide, 0]) {
		a = atan((bOffset) / dT);
		echo(a);
		rotate([-a, 180, 0]) {
			trap(tubeSide, d, bW - tubeThick * 2, tubeThick);
		}
	}
	translate([0, 0, 0]) {
		a = atan((bOffset) / dT);
		echo(a);
		rotate([-a, 180, 180]) {
			trap(tubeSide, d, bW - tubeThick * 2, tubeThick);
		}
	}

	dT2 = (bW - tubeSide) / 2 - tubeThick;
	d2 = sqrt(pow(dT2, 2) + pow(bOffset, 2));
	translate([tubeSide, 0, 0]) {
		a = atan((bOffset) / dT2);
		echo(a);
		rotate([-a, 180, -90]) {
			trap(tubeSide, d2, bD - tubeThick, tubeThick);
		}
	}
	translate([0, tubeSide, 0]) {
		a = atan((bOffset) / dT2);
		echo(a);
		rotate([-a, 180, 90]) {
			trap(tubeSide, d2, bD - tubeThick, tubeThick);
		}
	}
}

union() {
	tube(tH, tubeSide, tubeThick);
	translate([0, 0, tH]) {
		raiser();
	}

	translate([-bW/2 + tubeSide/2, -bD/2 + tubeSide/2 + tubeThick/2, tH + bOffset]) {
		box();
	}
}
