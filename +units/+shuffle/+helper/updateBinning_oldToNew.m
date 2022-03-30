function Binning = updateBinning_oldToNew(Binning)

% Centers stored by the names of the tuningCurve fields that they apply to
Binning.centers.stopWell = Binning.possibleStops;
Binning.centers.startWell = Binning.possibleStarts;
Binning.centers.currentDistance = Binning.distCenters;
Binning.centers.currentAngle = Binning.angleCenters;
Binning.centers.cuemem = Binning.possibleCuemem;

