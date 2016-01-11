#!/usr/bin/perl

my $directory = "~/Work/Images";
my $wellname = "WellC05";
my $imagenamebase = "DsRed - confocal - n";
my $fileext = ".tif";
my $digitsforenum = 6;
my $startindex = 1;
my $endindex = 10;
my $framestep = 1;
my $training = "~/CellAnimation/segmentation/segment/kernel01.mat";

for($i=$startindex; $i<=$endindex; $i = $i + $framestep)
{
	open(FILEID, ">job2.pbs");

	print(FILEID "#!/bin/bash\n");
	print(FILEID "#PBS -M samuel.w.hooke\@vanderbilt.edu\n");
	print(FILEID "#PBS -l nodes=1:ppn=1\n");
	print(FILEID "#PBS -l walltime=04:00:00\n");
	print(FILEID "#PBS -l mem=1gb\n");
	print(FILEID "#PBS -o testrun.out\n");
	print(FILEID "#PBS -j oe\n\n");

	#Directory above the one containing the raw images
	print(FILEID "export DIRECTORY=\"$directory\"\n");
	#Directory containing the raw images
	print(FILEID "export WELLNAME=\"$wellname\"\n");
	#Part of image names that all have in common
	print(FILEID "export IMAGENAMEBASE=\"$imagenamebase\"\n");
	#Extension on all images
	print(FILEID "export FILEEXT=\"$fileext\"\n");
	#How many digits long the image enumerations are
	print(FILEID "export DIGITSFORENUM=$digitsforenum\n");
	#image number to start segmenting on (multiplied by framestep)
	print(FILEID "export STARTINDEX=$i\n");
	#image number to finish segmenting on (multiplies by framestep)
	print(FILEID "export ENDINDEX=$i\n");
	#number of images to skip between iterations
	print(FILEID "export FRAMESTEP=1\n");
	#location of most recent output (raw images at start)
	print(FILEID "export OUTDIR=\$WELLNAME\n");
	#training set used to create classifier"
	print(FILEID "export TRAINING=\"$training\"\n");

	print(FILEID "cd ~/Work/CellAnimation/segmentation/segment\n\n");

	print(FILEID "matlab <AccreNaiveSegment.m\n");
	print(FILEID "export OUTDIR=\"\$WELLNAME/naive\"\n");
	print(FILEID "perl Classify.pl \"\$DIRECTORY/\$OUTDIR\" \\\n");
	print(FILEID "\"\$IMAGENAMEBASE\" \$STARTINDEX \$ENDINDEX \\\n");
	print(FILEID "\$DIGITSFORENUM\n");
	print(FILEID "matlab <AccreFinish.m \n\n");

	print(FILEID "matlab <AccreGMMSegment.m\n");
	print(FILEID "export OUTDIR=\"\$WELLNAME/gmm\"\n");
	print(FILEID "perl Classify.pl \"\$DIRECTORY/\$OUTDIR\" \\\n");
	print(FILEID "\"\$IMAGENAMEBASE\" \$STARTINDEX \$ENDINDEX \\\n");
	print(FILEID "\$DIGITSFORENUM\n");
	print(FILEID "matlab <AccreFinish.m\n");

	close(FILEID);
	system("qsub job2.pbs");
}
