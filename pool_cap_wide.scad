// ============================================================
//  Pool handrail anchor CAP  -  parametric OpenSCAD model
//
//  Built as THREE STACKED CYLINDERS, in build order:
//     UNIT 1  the base   - a full-width disc, the cap's visible face,
//                          lying flat ON THE BUILD PLATE, coin slot cut
//                          clean through it.
//     UNIT 2  the rim    - an annulus rising from the base's top face
//                          at the perimeter.
//     UNIT 3  the spigot - a tapered tube rising from the base's top
//                          face, centred, hollow.
//
//  Print in PETG or ASA. NOT PLA (humid, chloride-bearing vault).
// ============================================================
//
//  Units: millimetres.  (1 inch = 25.4 mm)
//
//  *** THIS MODEL IS PRE-FLIPPED ***
//  It is modelled ALREADY LYING ON ITS FACE, the way it prints.
//    z = 0  is the PRINT PLATE.
//    z grows UPWARD through the print.
//  Nothing needs rotating in Bambu Studio. Export the STL and slice.
//
//  In real-world terms, once you turn the finished part over:
//    the base  -> the visible top face of the cap
//    the rim   -> the proud ridge standing the cap off the step
//    the spigot-> the tube that drops into the railing hole
//
// ============================================================

/* [PARAMETERS] */

// ---- the visible face ----
CAP_OD          = 165;    // 6.5"  overall outside diameter
RIM_W           = 5.0;    // radial width of the rim wall
BASE_T          = 4.0;    // thickness of the base disc (the visible face).
                          // 3.0 is possible but thin for a 114 mm disc and
                          // this is the face you pry against.
TOTAL_H         = 6.35;   // overall height from the cap's face to the rim's
                          // top edge. 0.25" as specified.

// ---- the spigot that drops into the railing hole ----
// >>> SET THESE TWO FROM YOUR CALIPER READINGS. <<<
//   POST_OD_ROOT = where the spigot meets the base   (wide end)
//   POST_OD_OPEN = the free end, deepest in the pool (narrow end)
POST_OD_ROOT    = 49.3;   // measured at the base end of the spigot
POST_OD_OPEN    = 48.1;   // measured at the open end of the spigot
POST_L          = 76.2;   // 3"    how far it goes down the hole
POST_T          = 3.0;    // wall thickness of the hollow tube
POST_CHAMFER    = 2.0;    // chamfer at the open (deep) end

// ---- the coin slot ----
// Cut clean through the base, the whole way across it.
COIN_SLOT       = true;
SLOT_W_NARROW   = 3.0;    // screwdriver slot width
SLOT_W_COIN     = 4.5;    // coin-slot width (just over washer thickness)
SLOT_L_NARROW   = 34.0;   // length of the screwdriver slot
SLOT_L_COIN     = 40.0;   // coin-slot length (just over washer length)

// ---- the ballast retainer (printed separately, dropped in at a pause) ----
// This part is PRE-FLIPPED, so remember which way is which: in BED
// coordinates the bore WIDENS downward toward the plate. A disc dropped in
// at the pause therefore falls all the way DOWN to the base of the cap and
// comes to rest there. It cannot wedge on the taper, because it is falling
// into the widening end.
//
// Retention is by the WASHERS, which are fed in through the coin slot after
// printing and rest on top of the retainer. The retainer is sized to the
// bore where it actually RESTS (the base end), not to any intermediate
// plane, so it has just enough clearance to drop in but too little to cock
// sideways and escape past the washers.
//
//   PLUG_POS = 0  -> at the base end   (widest, where it rests)  <-- use this
//   PLUG_POS = 1  -> at the open end   (narrowest, never reached)
PLUG_POS        = 0.0;    // where the retainer RESTS along the spigot
PLUG_CLEAR      = 0.4;    // diametral running clearance. Large enough to
                          // drop in cleanly past printed bore irregularities,
                          // small enough that it cannot tip and slip by.
PLUG_T          = 3.0;    // retainer thickness
PLUG_HOLE       = 20.0;   // centre hole so water drains through. 0 = solid.

// ---- print quality ----
$fn             = 128;    // circle smoothness (raise = smoother, slower)

/* [Hidden] */

// ---- radii ----
R_CAP   = CAP_OD / 2;
R_RIM_I = R_CAP - RIM_W;      // inner radius of the rim = radius of the
                              // base's useful face inside the rim

// The spigot, defined directly by the two caliper readings.
// In BED coordinates the spigot grows UPWARD, so its WIDE (base) end is
// the LOW z and its NARROW (open) end is the HIGH z.
R_WIDTH_LO = POST_OD_ROOT / 2;   // radius at the base end   (low z)
R_WIDTH_HI = POST_OD_OPEN / 2;   // radius at the open end   (high z)

// ---- heights, ALL measured from z = 0 at the build plate ----
Z_BASE_TOP   = BASE_T;            // top of the base: everything else rises here
Z_SPIGOT_HI  = Z_BASE_TOP + POST_L;   // the spigot's open end

// ---- the bore, keeping a constant wall thickness ----
R_BORE_LO = R_WIDTH_LO - POST_T;   // bore radius at the base end
R_BORE_HI = R_WIDTH_HI - POST_T;   // bore radius at the open end

SLOT_W    = COIN_SLOT ? SLOT_W_COIN : SLOT_W_NARROW;
SLOT_L    = COIN_SLOT ? SLOT_L_COIN : SLOT_L_NARROW;

// ---- ballast retainer sizing ----
// Bore diameter at the chosen wedge plane, then trimmed by the clearance.
PLUG_BORE = 2*R_BORE_LO - PLUG_POS * (2*R_BORE_LO - 2*R_BORE_HI);
PLUG_OD   = PLUG_BORE - PLUG_CLEAR;

// ------------------------------------------------------------
//  UNIT 1 + 2 + 3, stacked
// ------------------------------------------------------------
module cap() {
    difference() {
        union() {

            // ============ UNIT 1  THE BASE ============
            // The cap's full visible face: a 114.3 mm disc lying flat on
            // the build plate. Every layer of the base is this disc, start
            // to finish, with no other geometry interleaved.
            cylinder(r = R_CAP, h = BASE_T, center = false);

            // ============ UNIT 2  THE RIM ============
            // An annulus rising from the base's top face at the perimeter.
            // Effective height above the base = TOTAL_H - BASE_T.
            translate([0, 0, Z_BASE_TOP])
                difference() {
                    cylinder(r = R_CAP, h = TOTAL_H - BASE_T, center = false);
                    translate([0, 0, -0.5])
                        cylinder(r = R_RIM_I, h = TOTAL_H - BASE_T + 1,
                                 center = false);
                }

            // ============ UNIT 3  THE SPIGOT ============
            // A tapered tube rising from the base's top face, centred.
            // r1 is the LOW-z radius = the wide, base end.
            translate([0, 0, Z_BASE_TOP])
                cylinder(r1 = R_WIDTH_LO, r2 = R_WIDTH_HI,
                         h = POST_L, center = false);
        }

        // ---- hollow the spigot: a true open tube ----
        // Overshoots 1 mm at BOTH ends so there is no bore/no-bore
        // transition inside any single layer.
        translate([0, 0, Z_BASE_TOP - 1])
            cylinder(r1 = R_BORE_LO, r2 = R_BORE_HI,
                     h = POST_L + 2, center = false);

        // ---- chamfer the open end of the spigot ----
        translate([0, 0, Z_SPIGOT_HI - POST_CHAMFER])
            cylinder(r1 = R_WIDTH_HI, r2 = R_WIDTH_HI - POST_CHAMFER,
                     h = POST_CHAMFER + 0.001, center = false);

        // ---- the coin slot ----
        // Cut clean through the WHOLE base, overshooting 1 mm at each end,
        // so it is a single slit through the full 114.3 mm face. Because
        // the base is one unbroken disc, the cutter never lands on a seam.
        translate([-SLOT_L/2, -SLOT_W/2, -1])
            cube([SLOT_L, SLOT_W, BASE_T + 2]);
    }
}

// ------------------------------------------------------------
// The ballast retainer. Printed as its own part and dropped into the
// spigot during a print pause. It falls until the narrowing taper
// closes on it. The centre hole lets water drain through.
module plug() {
    // Sits ON the build plate, offset clear of the cap.
    // The cap's widest solid is R_CAP (its base and rim). The retainer's
    // own radius is PLUG_OD/2, so the offset has to clear R_CAP + PLUG_OD/2
    // plus a gap, or the two parts overlap in X and collide on the plate.
    PLUG_GAP = 6.0;
    translate([R_CAP + PLUG_OD/2 + PLUG_GAP, 0, 0])
        difference() {
            cylinder(d = PLUG_OD, h = PLUG_T, center = false);
            if (PLUG_HOLE > 0)
                translate([0, 0, -0.5])
                    cylinder(d = PLUG_HOLE, h = PLUG_T + 1, center = false);
        }
}

// ------------------------------------------------------------
cap();
plug();

// ------------------------------------------------------------
//  THE BUILD, IN THE ORDER THE PRINTER SEES IT
//    z 0.00 -> 4.00    UNIT 1  the base (one full-width disc, slot cut)
//    z 4.00 -> 6.35    UNIT 2  the rim ring
//    z 4.00 -> 80.20   UNIT 3  the spigot (tapered tube)
//
//  Turned the right way up:
//    the base becomes the cap's visible face,
//    the rim stands TOTAL_H proud of the step,
//    the spigot hangs POST_L below.
//
//  ASSEMBLY ORDER
//    1. Print to the pause height (anywhere convenient).
//    2. Feed / drop the washers in first. They fall toward the narrow end.
//    3. Drop the retainer in after them.
//    4. Resume. The remaining layers close over, and the washers are
//       captive behind the retainer.
//
//  NOTES
//   * PLUG_CLEAR = 0 wedges precisely at PLUG_POS. Any clearance lets it
//     travel further down the shallow taper before it grips.
//   * Brim the print 8-10 mm; a 114 mm PETG disc lifts at the edges.
//   * PETG or ASA. Not PLA.
//   * Keep the BONDING CONDUCTOR at the hole intact. Cap over it.
// ------------------------------------------------------------

// ------------------------------------------------------------
//  Derived values, printed to the OpenSCAD console every run.
echo(str("--- pre-flipped: z=0 is the build plate ---"));
echo(str("base disc: dia=", CAP_OD, "  thickness=", BASE_T));
echo(str("rim: inner dia=", 2*R_RIM_I, "  height above base=", TOTAL_H - BASE_T));
echo(str("spigot OD: base end=", POST_OD_ROOT, "  open end=", POST_OD_OPEN));
echo(str("bore: base=", 2*R_BORE_LO, "  open=", 2*R_BORE_HI));
echo(str("slot: ", SLOT_L, " x ", SLOT_W, "  cut through the base"));
echo(str("retainer: OD=", PLUG_OD, "  hole=", PLUG_HOLE,
         "  wall=", (PLUG_OD - PLUG_HOLE)/2));
echo(str("total height on plate=", Z_SPIGOT_HI));
// ------------------------------------------------------------
