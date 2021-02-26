module rotate_about_pt3(pt, x, z, y) {
    translate(pt)
        rotate([x, y, z]) // CHANGE HERE
            translate(-pt)
                children();   
}

module rotate_about_pt(z, y, pt) {
    translate(pt)
        rotate([0, y, z]) // CHANGE HERE
            translate(-pt)
                children();   
}
   
module prism(l, w, h){
    polyhedron(
            points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
            faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
        );
}

module prism2(l, w) {
	polygon([[0,0], [l, 0], [l, w]]);
}

module tube(len,tubeSide,tubeThick,bCut=false,bAngle=0,tCut=false,tAngle=0) {
	difference() {
		cube([tubeSide,tubeSide,len]);
		if(bCut) {
			rotate_about_pt(bAngle, 0, [tubeSide/2, tubeSide/2,0]) {
				prism(tubeSide,tubeSide,tubeSide);
			}
		}
		if(tCut) {
			translate([0,0,len]) {
				rotate_about_pt(tAngle, 180, [tubeSide/2, tubeSide/2,0]) {
					prism(tubeSide,tubeSide,tubeSide);
				}
			}
		}
		translate([tubeThick,tubeThick,0]) {
			cube([tubeSide-2*tubeThick,tubeSide-2*tubeThick,len+1]);
		}
	}
}
