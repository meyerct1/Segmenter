#!/usr/bin/perl
#inputs:
#	0 - directory of image csv files
#	1 - directory of classifiers
#	2 - imageNameBase
#	3 - startIndex
#	4 - endIndex
#	5 - frameStep
#	6 - digitsForEnum

use strict;

my @classifications = ("debris", "nucleus", "under", "predivision", "postdivision", "newborn");

my $name;
my $image;
my $imNumStr;

foreach $name (@classifications)
{
  for($image = $ARGV[3]; $image <= $ARGV[4]; $image++)
  {
    $imNumStr = sprintf("%0$ARGV[6]d", $image * $ARGV[5]);
#    system("~/R-2.13.0/bin/R --vanilla --slave --args " .
    system("R --vanilla --slave --args " . 
					  "'$ARGV[0]' " .
					  "'$ARGV[1]' " . 
				      "'$ARGV[2]$imNumStr' " .
				      "'$name' " . 
		   		      "< PredictImage.R\n");
  }
}
