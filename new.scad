include <helper.scad>

//
// All numbers are in millimeter
//

thick = 5;

angleWidth = 50;
angleHeight = 50;
angleThick = 4;

// Firebox

fbW = 500;
fbD = 500;
fbH = 600;

/// Firebox basket

fbBkMinBottomOffset = 30;
fbBkMaxBottomOffset = 30;
fbBkHeight = 200;
fbBkNumRacks = 3;

/// Firebox door
fbDrD = fbD - 40;
fbDrH = fbH - 60;
fbDrHO = 20;

fbRotate = 50;

fbDrBandWidth = 60;
fbDrBandThick = 6;

// Smoke Stack
ssW = fbW;
ssD = fbD;
ssH = 800;

/// Smoke Stack door
ssDrW = ssW - 40;
ssDrH = ssH - 60;
ssDrHO = 20;

ssDrRotate = 50;

ssDrBandWidth = fbDrBandWidth;
ssDrBandThick = fbDrBandThick;

/// FireBox Crates

ssCrMinBottomOffset = 30;
ssCrMaxOffset = 70;
ssCrNumRacks = 5;

// Chamber

chamBottomD = 200;
chamTopD = 200;
chamBackH = 300;
chamFrontH = 300;
chamWidth = 800;
chamOffset = 350; // the Z offset of the chamber in relation to the firebox
chamHeight = 600;
chamFrontBackOffset = 150;

/// Chamber Door

chamDoorWidth = chamWidth - 100;
chamDoorDepth = 250;
chamDoorHeight = 325;
chamDoorRotate = 70;

chamBandWidth = fbDrBandWidth;
chamBandThick = fbDrBandThick;

/// Chamber Face Door

chamFaceDoorHeight = 75;
chamFaceSealWidth = 30;
chamFaceDoorRotate = 90;

chamFaceBandWidth = fbDrBandWidth;
chamFaceBandThick = fbDrBandThick;

// Firebox - Chamber Hatch

fbChamPercentOpen = 0.5;

module angle(l) {
	union() {
		cube([angleWidth, l, angleThick]);	
		translate([0,0, -(angleHeight - angleThick)]) {
			cube([angleThick, l, angleHeight - angleThick]);
		}
	}
}

module box(plan, x, y) {
	if(plan) {
		square(size=[x, y]);
	} else {
		cube([x, y, thick]);
	}
}

module text2(plan, t, x, y, zR = 0) {
	translate([x, y, 0]) {
		rotate([0, 0, zR]) {
			if(plan) {
				text(t, size=40);
			} else {
				linear_extrude(height = thick) {
					text(t, size=40);
				}
			}
		}
	}
}

module doc(plan, top, wText, wPos, dText, dPos) {
	if(plan) {
		echo(str("\"",top, "\", ", wPos, ", ", dPos));
		text2(plan, top, 0, dPos + 70);
		text2(plan, str(wText, " = ", wPos), 0, dPos + 20);
		text2(plan, str(dText, " = ", dPos), wPos + 20, dPos, 270);
	}	
}

tubeSide=100;
tubeThick=3;
tubeIns=2;

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
   
module tube(len,bCut=false,bAngle=0,tCut=false,tAngle=0) {
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

// Chamber Begin

module chamBottom(plan) {
	box(plan, chamWidth, chamBottomD);
	doc(plan, "Chamber bottom", "W", chamWidth, "D", chamBottomD);
}

module chamTop(plan) {
	box(plan, chamWidth, chamTopD);
	doc(plan, "Chamber top", "W", chamWidth, "D", chamTopD);
}

module chamFront(plan) {
	box(plan, chamWidth, chamFrontH);
	doc(plan, "Chamber front", "W", chamWidth, "H", chamFrontH);
}

module chamBack(plan) {
	box(plan, chamWidth, chamBackH);
	doc(plan, "Chamber back", "W", chamWidth, "H", chamBackH);
}

module chamBottomFront(plan) {
	dB = (fbD - chamBottomD) / 2;
	h = sqrt(pow(dB, 2) + pow(chamFrontBackOffset - thick, 2));
	box(plan, chamWidth, h);
	doc(plan, "Chamber bottom front", "W", chamWidth, "H", h);
}

module chamBottomBack(plan) {
	dB = (fbD - chamBottomD) / 2;
	h = sqrt(pow(dB, 2) + pow(chamFrontBackOffset - thick, 2));
	box(plan, chamWidth, h);
	doc(plan, "Chamber bottom back", "W", chamWidth, "H", h);
}

module chamBackTop(plan) {
	dB = (fbD - chamTopD) / 2;
	h = sqrt(pow(dB, 2) + pow(chamHeight - chamBackH - chamFrontBackOffset, 2));
	box(plan, chamWidth, h);
	doc(plan, "Chamber back top", "W", chamWidth, "H", h);
}

module chamFrontTop(plan) {
	dB = (fbD - chamTopD) / 2;
	h = sqrt(pow(dB, 2) + pow(chamHeight - chamFrontH - chamFrontBackOffset, 2));
	box(plan, chamWidth, h);
	doc(plan, "Chamber front top", "W", chamWidth, "H", h);
}

module chamFaceDoor(plan, bands=false) {
	dT = (fbD - chamTopD) / 2;
	dB = (fbD - chamBottomD) / 2;
	d = chamTopD < chamBottomD ? chamTop : chamBottomD;
	dS = fbD - d;

	union() {
		sealWidth = chamFaceSealWidth / 2;
		translate([0, dS / 2 + d + dT - sealWidth, thick]) {
			if(plan) {
				translate([-(chamFrontBackOffset - sealWidth - thick), -dB + sealWidth, -thick]) {
					rotate([0,0,0]) {
						prism2(chamFrontBackOffset - thick - sealWidth, dB - sealWidth);
					}
				}
			} else {
				rotate([180,90,0]) {
					prism(thick, dB - sealWidth, chamFrontBackOffset - thick - sealWidth);
				}
			}
		}
		translate([0, +sealWidth, 0]) {
			if(plan) {
				translate([0, 0, 0]) {
					rotate([0,0,90]) {
						prism2(dB - sealWidth, chamFrontBackOffset - thick - sealWidth);
					}
				}
			} else {
				rotate([180,-90,180]) {
					prism(thick, dB - sealWidth, chamFrontBackOffset - thick - sealWidth);
				}
			}
		}
		translate([0, dB, thick]) {
			if(plan) {
				translate([0, 0, -thick]) {
					rotate([180,0,180]) {
						box(plan, chamFrontBackOffset - thick - sealWidth, chamBottomD);
					}
				}
			} else {
				rotate([180,0,180]) {
					box(plan, chamFrontBackOffset - thick - sealWidth, chamBottomD);
				}
			}
		}
		if(bands) {
			translate([-(chamFaceBandWidth + sealWidth * 2), dB, thick + chamFaceBandThick]) {
				rotate([180,0,180]) {
					cube([chamFaceBandWidth, chamBottomD, chamFaceBandThick]);
				}
			}
		}
		translate([0, sealWidth, 0]) {
			if(plan) {
				translate([0, 0, 0]) {
					rotate([0,0,0]) {
						box(plan, chamFaceDoorHeight, fbD - chamFaceSealWidth);
					}
				}
			} else {
				rotate([0,0,0]) {
					box(plan, chamFaceDoorHeight, fbD - chamFaceSealWidth);
				}
			}
		}
		if(bands) {
			translate([(chamFaceDoorHeight + sealWidth * 2), 0, thick + chamFaceBandThick]) {
				rotate([180,0,180]) {
					cube([chamFaceBandWidth, fbD + thick, chamFaceBandThick]);
				}
			}
		}
		if(bands) {
			translate([(chamFaceDoorHeight - sealWidth * 2), 0, thick + chamFaceBandThick]) {
				rotate([180,0,180]) {
					cube([chamFaceBandWidth - sealWidth, chamFaceBandWidth, chamFaceBandThick]);
				}
			}
			translate([(chamFaceDoorHeight - sealWidth * 2), fbD - chamFaceBandWidth + thick, thick + chamFaceBandThick]) {
				rotate([180,0,180]) {
					cube([chamFaceBandWidth - sealWidth, chamFaceBandWidth, chamFaceBandThick]);
				}
			}
			dB = (fbD - chamBottomD) / 2;
			h2 = sqrt(pow(dB, 2) + pow(chamFrontBackOffset - thick, 2));
			translate([-thick/2, -thick/2, thick]) {
				d = dB;
				h = chamFrontBackOffset - thick;

				angle = atan(h / d);
				
				rotate([0, 0, angle]) {
					cube([chamFaceBandWidth, h2, chamFaceBandThick]);
				}
			}
			translate([0, fbD+thick, thick]) {
				d = dB;
				h = chamFrontBackOffset - thick;

				angle = atan(h / d);
				rotate([0, 0, 180-angle]) {
					translate([-chamFaceBandWidth, 0, 0]) {
						cube([chamFaceBandWidth, h2, chamFaceBandThick]);
					}
				}
			}
		}
	}
}

module chamFace(plan) {
	dT = (fbD - chamTopD) / 2;
	dB = (fbD - chamBottomD) / 2;
	d = chamTopD < chamBottomD ? chamTop : chamBottomD;
	dS = fbD - d;
	difference() {
		union() {
			translate([0, dT < dB ? dT : dB, 0]) {
				box(plan, chamHeight - thick, d);
			}

			translate([chamFrontBackOffset - thick, 0, 0]) {
				box(plan, chamFrontH, dS / 2);
			}

			translate([chamFrontBackOffset - thick, dS / 2 + d, 0]) {
				box(plan, chamBackH, dS / 2);
			}

			translate([chamFrontBackOffset + chamBackH - thick, dS / 2 + d + dT, 0]) {
				if(plan) {
					rotate([0,0,-90]) {
						prism2(dT, chamHeight - chamFrontBackOffset - chamBackH);
					}
				} else {
					rotate([0,-90,180]) {
						prism(thick, dT, chamHeight - chamFrontBackOffset - chamBackH);
					}
				}
			}

			translate([chamFrontBackOffset + chamFrontH - thick, 0, thick]) {
				if(plan) {
					translate([chamHeight - chamFrontBackOffset - chamFrontH, dT, -thick]) {
						rotate([0,0,-180]) {
							prism2(chamHeight - chamFrontBackOffset - chamFrontH, dT);
						}
					}
				} else {
					rotate([0,90,0]) {
						prism(thick, dT, chamHeight - chamFrontBackOffset - chamBackH);
					}
				}
			}

			translate([chamFrontBackOffset - thick, dS / 2 + d + dT, thick]) {
				if(plan) {
					translate([-(chamFrontBackOffset - thick), -dB, -thick]) {
						rotate([0,0,0]) {
							prism2(chamFrontBackOffset - thick, dB);
						}
					}
				} else {
					rotate([180,90,0]) {
						prism(thick, dB, chamFrontBackOffset - thick);
					}
				}
			}

			translate([chamFrontBackOffset - thick, 0, 0]) {
				if(plan) {
					translate([0, 0, 0]) {
						rotate([0,0,90]) {
							prism2(dB, chamFrontBackOffset - thick);
						}
					}
				} else {
					rotate([180,-90,180]) {
						prism(thick, dB, chamFrontBackOffset - thick);
					}
				}
			}
		}
		translate([chamFrontBackOffset - thick, 0, 0]) {
			chamFaceDoor(plan);
		}
	}

	if(!plan) {
		translate([chamFrontBackOffset-thick,0,0]) {
			rotate_about_pt3([chamFrontBackOffset - thick, fbD + thick, thick]
				, -chamFaceDoorRotate, 0, 0) 
			{
				chamFaceDoor(plan, true);
			}
		}
	}

	if(plan) {
		text2(plan, "Cham face", 10, fbD + 180, 0);
		text2(plan, str("Overall = ", chamHeight), chamFrontBackOffset, fbD + 80, 0);
		text2(plan, str("Back = ", chamBackH), chamFrontBackOffset, fbD + 30, 0);
		text2(plan, str("Front = ", chamFrontH), chamFrontBackOffset, -70, 0);
		text2(plan, str("FrontBackOffset = ", chamFrontBackOffset), chamFrontBackOffset, -140, 0);
		text2(plan, str("Cham top = ", chamTopD), chamHeight + 30, fbD, -90);
		text2(plan, str("Cham bottom = ", chamBottomD), -50, fbD, -90);
	}
}

module chamCoalBasket(plan) {
	rotate([0,270,0]) {
		angle(chamWidth);
	}	
	translate([fbD - thick / 2, 0, 0]) {
		rotate([0,180,0]) {
			angle(chamWidth);
		}	
	}
}

module chamGrades(plan) {
	rotate([0,180,0]) {
		angle(fbD + thick);
	}
	translate([-chamDoorWidth - angleThick, 0, -angleThick]) {
		rotate([0,270,0]) {
			angle(fbD + thick);
		}
	}
}

// Chamber End

// Smoke stack Begin

module ssBack(plan) {
	box(plan, ssW, ssH);
	doc(plan, "Smoke stack back", "W", ssW, "H", ssH);
}

module ssFront(plan) {
	h = ssH - thick;
	wDP = (ssW - ssDrW) / 2;
	difference() {
		box(plan, ssW, ssH);
		translate([ssDrHO,wDP,0]) {
			box(plan, ssDrW, ssDrH);
		}
	}
	doc(plan, "Smoke front", "W", ssW, "H", ssH);
	if(plan) {
		text2(plan, str("W = ", ssDrW), ssW - 250, wDP + 20);
		text2(plan, str("H = ", ssDrH), ssDrHO + 20, ssDrH, -90);
		text2(plan, str("H.Os = ", ssDrHO), ssW - ssDrW + 30, ssDrHO + 20, 90);
		text2(plan, str("W.Os = ", wDP), ssW - 300, ssH - (ssH - ssDrH + ssDrHO + 20));
	}
}

module ssDoor(plan) {
	echo(str("ssDrBandWidth ", ssDrBandWidth));
	echo(str("ssDrBandThick ", ssDrBandThick));
	box(plan, ssDrH, ssDrW);

	translate([-ssDrHO, -20, thick]) {
		cube([ssDrH + ssDrHO * 2, ssDrBandWidth, ssDrBandThick]);
	}

	translate([-ssDrHO, ssDrW + 20 - ssDrBandWidth, thick]) {
		cube([ssDrH + ssDrHO * 2, ssDrBandWidth, ssDrBandThick]);
	}

	translate([-ssDrHO, -20 + ssDrBandWidth, thick]) {
		cube([ssDrBandWidth, ssW - (2 * ssDrBandWidth), ssDrBandThick ]);
	}

	translate([ssDrH - ssDrBandWidth + ssDrHO, -20 + ssDrBandWidth, thick]) {
		cube([ssDrBandWidth, ssW - (2 * ssDrBandWidth), ssDrBandThick ]);
	}
}

module ssRight(plan) {
	h = ssH - thick;
	box(plan, h, ssD);
	doc(plan, "Smoke stack right", "H", h, "D", ssD);
}

module ssLeft(plan) {
	h = ssH - thick;
	box(plan, h, ssD);
	doc(plan, "Smoke stack left", "H", h, "D", ssD);
}

module ssTop(plan) {
	box(plan, ssW, ssD);
	doc(plan, "Smoke stack top", "W", ssW, "D", ssD);
}

module ssCrates(plan) {
	h = (ssH - ssCrMaxOffset - angleHeight) - (ssCrMinBottomOffset + angleHeight);
	echo(str("SS.H ", h));
	stepHeight = h / (ssCrNumRacks - 1);
	echo(str("SS.S ", stepHeight));
	for(i = [(ssCrMinBottomOffset + angleHeight) : stepHeight : (ssH - ssCrMaxOffset)]) {
		echo(str("SS.i ", i));
		translate([ssD,thick,i]) {
			rotate([0,0,90]) {
				angle(ssD);
			}
		}
		translate([0,ssD-thick,i]) {
			rotate([0,0,-90]) {
				angle(ssD);
			}
		}
	}
}

module ssBuild(plan) {
	translate([0,ssD+thick,fbH+thick]) {
		rotate([90,0,0]) {
			ssBack(plan);
		}
	}
	translate([0,0,fbH+thick]) {
		rotate([90,0,0]) {
			ssFront(plan);
		}
	}

	translate([ssW,0,fbH+thick]) {
		rotate([0,-90,0]) {
			ssRight(plan);
		}
	}

	translate([thick,0,fbH+thick]) {
		rotate([0,-90,0]) {
			ssLeft(plan);
		}
	}

	translate([0,0,fbH+ssH]) {
		rotate([0,0,0]) {
			ssTop(plan);
		}
	}

	translate([ssW,0,fbH + thick]) {
		rotate([0,0,90]) {
			ssCrates(plan);
		}
	}

	translate([(ssW - ssDrW) / 2, 0, fbH + ssDrH + ssDrHO + thick]) {
		rotate([90,90,0]) {
			rotate_about_pt3([0, ssDrW + 20, 5], -ssDrRotate, 0, 0) {
				ssDoor(plan);
			}
		}
	}
}

module ssPlan(plan) {
	ssBack(plan);
	translate([0, ssH + 220, 0]) {
		ssFront(plan);
	}

	translate([ssW + 180, 0, 0]) {
		ssRight(plan);

		translate([0, ssD + 220, 0]) {
			ssLeft(plan);
			translate([0, ssD + 220, 0]) {
				ssTop(plan);
			}
		}
	}
}

// Smoke stack End

// Firebox Begin

module fbBottom(plan) {
	box(plan, fbW, fbD);
	doc(plan, "Firebox bottom", "W", fbW, "D", fbD);
}

module fbBack(plan) {
	box(plan, fbW, fbH);
	doc(plan, "Firebox back", "W", fbW, "H", fbH);
}

module fbFront(plan) {
	box(plan, fbW, fbH);
	doc(plan, "Firebox front", "W", fbW, "H", fbH);
}

module fbRight(plan) {
	h = fbH - thick;
	dDP = (fbD - fbDrD) / 2;
	difference() {
		box(plan, h, fbD);
		translate([fbDrHO,dDP,0]) {
			box(plan, fbDrH, fbDrD);
			//doc(plan, "Firebox door", "H", fbDrH, "D", fbDrD);
		}
	}
	doc(plan, "Firebox right", "H", h, "D", fbD);
	if(plan) {
		text2(plan, str("H = ", fbDrH), fbH - (fbDrHO + 240), dDP + 20);
		text2(plan, str("D = ", fbDrD), fbDrHO + 20, fbD - (dDP + 20), -90);
		text2(plan, str("H.Os = ", fbDrHO), fbDrHO, dDP + 20);
		text2(plan, str("D.Os = ", dDP), fbH - (fbH - fbDrH + fbDrHO + 20), fbD - (dDP + 20), -90);
	}
}

module fbLeft(plan) {
	h = fbH - thick;
	doc(plan, "Firebox left", "H", h, "D", fbD);
	difference() {
		box(plan, h, fbD);
		dT = (fbD - chamTopD) / 2 - 30;
		dB = (fbD - chamBottomD) / 2 - 30;
		d = chamTopD < chamBottomD ? chamTop : chamBottomD;
		dS = fbD - d;
		if(plan) {
			translate([chamOffset, fbD - dB - 30, 0]) {
				rotate([0,0,0]) {
					prism2(chamFrontBackOffset - thick, dB);
				}
			}
			translate([chamOffset, fbD - dB - 30 - chamBottomD, 0]) {
				square([chamFrontBackOffset - thick, chamBottomD]);
			}
		} else {
			translate([chamOffset + dB + 30 - thick, fbD - 30, thick]) {
				rotate([0,90,180]) {
					prism(thick, dB, dB);
				}
			}
			translate([chamOffset + 30 - thick, fbD - chamBottomD - dB - 30, 0]) {
				cube([chamFrontBackOffset - 30, chamBottomD, thick]);
			}
		}
	}
}

module fbTop(plan) {
	d = fbD + (thick * 2);
	box(plan, fbW, d);
	doc(plan, "Firebox top", "W", fbW, "D", d);
}

module fbPlan(plan) {
	fbBottom(plan);
	translate([0, fbD + 220, 0]) {
		fbBack(plan);
		translate([0, fbH + 180, 0]) {
			fbFront(plan);
		}
	}

	translate([fbW + 180, 0, 0]) {
		fbRight(plan);

		translate([0, fbD + 220, 0]) {
			fbLeft(plan);
			translate([0, fbD + 220, 0]) {
				fbTop(plan);
			}
		}
	}

}

module fbBasketSlots(plan) {
	h = (fbH - fbBkMaxBottomOffset - angleHeight) - (fbBkMinBottomOffset + fbBkHeight - angleHeight);
	stepHeight = h / (fbBkNumRacks - 1);
	echo(stepHeight);
	for(i = [(fbBkMinBottomOffset + fbBkHeight - angleHeight) : stepHeight : (fbH - fbBkMaxBottomOffset - angleHeight)]) {
		echo(i);
		translate([fbW-thick,0,i]) {
			rotate([0,0,90]) {
				angle(fbW-thick*2);
			}
		}
		translate([thick,fbD,i]) {
			rotate([0,0,-90]) {
				angle(fbW-thick*2);
			}
		}
	}
}

module fbDoor(plan) {
	echo(str("fbDrBandWidth ", fbDrBandWidth));
	echo(str("fbDrBandThick ", fbDrBandThick));
	box(plan, fbDrH, fbDrD);

	translate([-fbDrHO, - ((fbD + 2 * thick) - fbDrD) / 2 , thick]) {
		cube([fbDrH + fbDrHO * 2, fbDrBandWidth, fbDrBandThick]);
	}

	translate([-fbDrHO, fbDrD - fbDrBandWidth / 2 - thick, thick]) {
		cube([fbDrH + fbDrHO * 2, fbDrBandWidth, fbDrBandThick]);
	}

	translate([-fbDrHO, fbDrBandWidth / 2 + thick, thick]) {
		cube([fbDrBandWidth, (fbD + thick * 2) - (fbDrBandWidth * 2), fbDrBandThick ]);
	}

	translate([fbDrH - fbDrBandWidth + fbDrHO, fbDrBandWidth / 2 + thick, thick]) {
		cube([fbDrBandWidth, (fbD + thick * 2) - (fbDrBandWidth * 2), fbDrBandThick ]);
	}
}

module fbBuild(plan) {
	fbBottom(plan);
	difference() {
		union() {
			translate([0,fbD+thick,0]) {
				rotate([90,0,0]) {
					fbBack(plan);
				}
			}
			translate([0,0,0]) {
				rotate([90,0,0]) {
					fbFront(plan);
				}
			}
			translate([fbW,0,thick]) {
				rotate([0,-90,0]) {
					//fbRight(plan);
				}
			}

			translate([thick,0,thick]) {
				rotate([0,-90,0]) {
					fbLeft(plan);
				}
			}

			translate([0,-thick,fbH]) {
				rotate([0,0,0]) {
					fbTop(plan);
				}
			}
			fbBasketSlots(plan);
		}
		union() {
			dT = (fbD - chamTopD) / 2 - 30;
			dB = (fbD - chamBottomD) / 2 - 30;
			d = chamTopD < chamBottomD ? chamTop : chamBottomD;
			dS = fbD - d;
			if(plan) {
				translate([0,0,0]) {
					rotate([0,0,0]) {
						prism2(chamFrontBackOffset - thick, dB);
					}
				}
			} else {
				translate([0, fbW - 30, chamOffset + dB + 30]) {
					rotate([180,0,0]) {
						prism(thick, dB, dB);
					}
				}
			}
		}
	}

	translate([fbW - thick, (fbD - fbDrD) / 2, fbDrH + fbDrHO]) {
		rotate([0,90,0]) {
			rotate_about_pt3([0, fbDrD + (fbD - fbDrD) / 2 + thick - chamBandWidth / 2, thick], -fbRotate, 0, 0) {
				fbDoor(plan);
			}
		}
	}
}

module chamBuild(plan, door = true) {
	difference() {
		union() {
			dB = (fbD - chamBottomD) / 2;
			translate([-(chamWidth), dB, chamOffset]) {
				chamBottom(plan);
			}

			dT = (fbD - chamTopD) / 2;
			translate([-chamWidth, dT, chamOffset + chamHeight]) {
				//chamTop(plan);
			}

			translate([-chamWidth, 0, chamOffset + chamFrontBackOffset]) {
				rotate([90,0,0]) {
					chamFront(plan);
				}
			}

			translate([-chamWidth, fbD + thick, chamOffset + chamFrontBackOffset]) {
				rotate([90,0,0]) {
					chamBack(plan);
				}
			}

			translate([-chamWidth, dB, chamOffset + thick]) {
				d = dB;
				h = chamFrontBackOffset - thick;

				angle = atan(h / d);
				echo(str("Chamber angle bottom front ", angle));
				
				rotate([180 - angle,0,0]) {
					chamBottomFront(plan);
				}
			}
			
			translate([-chamWidth, fbD, chamOffset + chamFrontBackOffset]) {
				d = dB;
				h = chamFrontBackOffset - thick;

				angle = atan(h / d);
				echo(str("Chamber angle bottom back ", angle));
				
				rotate([180 + angle,0,0]) {
					chamBottomBack(plan);
				}
			}
			
			dbt = (fbD - chamTopD) / 2;
			translate([-chamWidth, dT + chamTopD, chamOffset + chamHeight]) {
				h = chamHeight - chamBackH - chamFrontBackOffset;

				angle = atan(h / dbt);
				echo(str("Chamber angle top back ", angle));
				rotate([-angle,0,0]) {
					//chamBackTop(plan);
				}
			}

			translate([-chamWidth, 0, chamOffset + chamFrontBackOffset + chamFrontH]) {
				h = chamHeight - chamFrontH - chamFrontBackOffset;

				angle = atan(h / dbt);
				echo(str("Chamber angle top front ", angle));
				rotate([angle,0,0]) {
					//chamFrontTop(plan);
				}
			}

			translate([-chamWidth + thick, 0, chamOffset + thick]) {
				rotate([0,-90,0]) {
					chamFace(plan);
				}
			}

			translate([0, angleThick, chamOffset + chamFrontBackOffset + angleWidth / 2 ]) {
				rotate([0,0,90]) {
					chamCoalBasket(plan);
				}
			}

		}
		if(door) {
			translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 )), -thick, chamOffset + chamHeight - chamDoorHeight + thick]) {
				cube([chamDoorWidth, chamDoorDepth, chamDoorHeight]);
			}
		}
	}

	if(door) {
		rotate_about_pt3([-chamWidth, chamDoorDepth - thick + chamBandWidth / 2, chamOffset + chamHeight + thick]
				, -chamDoorRotate, 0, 0) 
		{
			//chamDoor();
		}
	}

	translate([-angleWidth + angleThick, 0, chamOffset + chamHeight - chamDoorHeight + thick]) {
		chamGrades(plan);
	}

	translate([-angleWidth + angleThick, 0, chamOffset + chamHeight - chamDoorHeight + thick + 100]) {
		chamGrades(plan);
	}
}

module chamDoor() {
	union() {
		intersection() {
			chamBuild(false, false);
			translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 )), -thick, chamOffset + chamHeight - chamDoorHeight + thick]) {
				cube([chamDoorWidth, chamDoorDepth, chamDoorHeight]);
			}
		}

		hc = chamFrontH - (chamHeight - chamDoorHeight - chamFrontBackOffset + thick)
			+ chamBandWidth / 2;
		frontHeight = chamOffset + chamHeight - chamDoorHeight + thick - chamBandWidth / 2;
		translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2))
				, -(thick + chamBandThick) 
				, frontHeight]) 
		{
			cube([chamBandWidth, chamBandThick, hc]);
		}

		translate([-(chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2
				, -(thick + chamBandThick) 
				, frontHeight]) 
		{
			cube([chamBandWidth, chamBandThick, hc]);
		}

		translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 + chamBandWidth / 2))
				, -(thick + chamBandThick) 
				, frontHeight]) 
		{
			cube([chamDoorWidth - chamBandWidth, chamBandThick, chamBandWidth]);
		}

		dB = (fbD - chamTopD) / 2;
		l = sqrt(pow(dB, 2) + pow(chamHeight - chamFrontH - chamFrontBackOffset, 2));
		h = chamHeight - chamFrontH - chamFrontBackOffset;
		angle = atan(h / dB);
		translate([-(chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2
				, 0
				, chamOffset + chamFrontBackOffset + chamFrontH]) 
		{
			rotate([angle, 0, 0]) {
				translate([0, 0, thick]) {
					cube([chamBandWidth, l, chamBandThick]);
				}
			}
		}
		translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2))
				, 0
				, chamOffset + chamFrontBackOffset + chamFrontH]) 
		{
			rotate([angle, 0, 0]) {
				translate([0, 0, thick]) {
					cube([chamBandWidth, l, chamBandThick]);
				}
			}
		}

		topBandLength = chamDoorDepth - (fbD - chamTopD) / 2 - thick;
		translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2))
				, (fbD - chamTopD) / 2
				, chamOffset + chamHeight + thick]) 
		{
			cube([chamBandWidth, topBandLength + chamBandWidth / 2, chamBandThick]);
		}

		translate([-(chamWidth - chamDoorWidth) / 2 - chamBandWidth / 2
				, (fbD - chamTopD) / 2
				, chamOffset + chamHeight + thick]) 
		{
			cube([chamBandWidth, topBandLength + chamBandWidth / 2, chamBandThick]);
		}

		translate([-(chamWidth - ((chamWidth - chamDoorWidth) / 2 + chamBandWidth / 2))
				, (fbD - chamTopD) / 2 + topBandLength - chamBandWidth / 2
				, chamOffset + chamHeight + thick]) 
		{
			cube([chamDoorWidth - chamBandWidth, chamBandWidth, chamBandThick]);
		}
	}
}

module chamPlan(plan = false) {
	chamBottom(plan);
	translate([0, chamBottomD + 220, 0]) {
		chamTop(plan);
		translate([0, chamTopD + 220, 0]) {
			chamBottomFront(plan);
			translate([0, chamTopD + 220, 0]) {
				chamBack(plan);
			}
		}

	}
	translate([chamWidth + 200, 0, 0]) {
		chamBottomBack(plan);
		dB = (fbD - chamTopD) / 2;
		h = sqrt(pow(dB, 2) + pow(chamHeight - chamBackH - chamFrontBackOffset, 2));
		translate([0, h + 200, 0]) {
			chamBackTop(plan);
			dB2 = (fbD - chamTopD) / 2;
			h2 = sqrt(pow(dB, 2) + pow(chamHeight - chamFrontH - chamFrontBackOffset, 2));
			translate([0, h2 + 200, 0]) {
				chamFrontTop(plan);
				translate([0, chamTopD + 220, 0]) {
					chamFront(plan);
				}
			}
		}
	}

	translate([chamWidth * 2 + 500, 0, 0]) {
		chamFace(plan);
	}
}

module fb(plan = false) {
	if(plan) {
		fbPlan(plan);
	} else {
		fbBuild(plan);
	}
}

module ss(plan = false) {
	if(plan) {
		ssPlan(plan);
	} else {
		ssBuild(plan);
	}
}

module cham(plan = false) {
	if(plan) {
		chamPlan(plan);
	} else {
		chamBuild(plan);
	}
}

module exhaustBuild() {
	dbt = (fbD - chamTopD) / 2;
	h = chamHeight - chamBackH - chamFrontBackOffset;
	angle = atan(h / dbt);

	echo(str("Exhaust tube angle ", angle));

	translate([-100, fbD - tubeSide * 1.0, chamOffset + chamFrontBackOffset + chamBackH]) {
		difference() {
			tube(700);
			translate([0,-200,-200]) {
				rotate_about_pt3([0,300,200],-angle,0,0) {
					cube([tubeSide,300,200]);
				}
			}
		}
	}

	translate([-chamWidth + 5, fbD - tubeSide * 1.0, chamOffset + chamFrontBackOffset + chamBackH]) {
		difference() {
			tube(700);
			translate([0,-200,-200]) {
				rotate_about_pt3([0,300,200],-angle,0,0) {
					cube([tubeSide,300,200]);
				}
			}
		}
	}
}

// Firebox End


// Plan
module showPlan() {
	fb(true);
	translate([(fbW < fbH ? fbH : fbW) * 2 + 400, 0, 0]) {
		ss(true);
	}
	
	translate([0, (fbH < fbD ? fbD : fbH) * 3 + 700, 0]) {
		cham(true);
	}
}

// Build
module showBuild() {
	translate([-1000,0,0]) {
		fb(false);
		//ss(false);
		cham(false);
		//exhaustBuild();
	}
}

showBuild();
showPlan();
