#!/usr/bin/perl

# this script was written by Will Isley
# the author of this script is not responible for any mishaps as a result of using this script
# this has been tested to function with gaussian 09 output files
# 
# Temperature is set to 298.15 K, and frequency corrections are performed for frequencies below 50 wavenumbers
# The entropic and ZPE terms are corrected
#
# Update v1.2: Change log: update the parsing of frequencies so undefined frequences are not appended to the array
#
# Update v1.1: Change log: updated the reporting of variables to correctly reflect gibbs, enthalpy and entropy
#
# last updated January 31th 2013


use strict;
use warnings;
use Getopt::Long;

# constants
my $Rconst = 1.9858775/1000;
my $kb = 0.69503476;
my $T = 298.15;
my $hartreetokcal = 627.509;
my $imagflag = 0;
my $freqScalingFactor = 1.000;
my $help = "\nThis script corrects for low-frequencies
The default cutoff wavenumber is 50 cm^-1
The default temperature is 298.15 K
The default frequency scaling factor is set to 1.0

Options available for the script (include these before your the filename):
--temp=X or --t=X        ; Change the temperature used to X
--corrFreq=X or --cf=X   ; Change the cutoff frequency used to X
--freqScale=X or --fs=X  ; Scale all frequencies used in the calcualtion by X
--isTS                   ; Frequencies are for a transitions state, so the the first negative frequency will be ignored

Examples:
Change cutoff wavenumber to 100 cm^-1       ; perl freq_replacement_g09.pl --cf=100 filename.out
Change cutoff to 75 and temperature to 300  ; perl freq_replacement_g09.pl --cf=75 --t=300 filename.out
Run the script for a transition state       ; perl freq_replacement_g09.pl --isTS filename.out
Change frequency scaling to 0.978           ; perl freq_replacement_g09.pl --fs=0.978 filename.out

Any number of options can be combined as shown in the 2nd example";
my $printHelp=0;

# electronic spin 
my $S_2;
my $S_2_ideal;

# variables for making the corrections
my @frequencies;
my $Thermal_vib_corr=0.0;
my $ZPE_corr=0.0;
my $entropycorr = 0.0;
my $gibbscorr = 0.0;

# the new replacement frequency
my $corrFreq = 50.00000;

# variables read in from gaussian output file
my $electronicEnergy;
my $ZPEread;
my $ZPEelectronic;
my $enthalpyread;
my $thermalEnthalpy;
my $gibbsread;
my $thermalFreeEnergy;
my $thermalflag=0;
my $TS_on=0;

# variables for final corrections
my $enthalpy_total_corr;
my $gibbs_total_corr;

GetOptions ('help|h' => \$printHelp,
            'temp|t=f' => \$T,
            'corrFreq|cf=f' => \$corrFreq,
            'freqScale|fs=f' => \$freqScalingFactor,
            'isTS' => \$TS_on)
or die("Error in command line arguments");

if ($printHelp){
    print "$help\n";
    exit 0;
} 

# input file
my $file=$ARGV[0]; #this reads the output file

open(INFILE, "<$file") or die;
print "Reading ".$file."\n";

while (my $line = <INFILE>){
   if ($line =~ /Frequencies/) { #search for all frequencies 
      my @linesplit = split(/\s+/,$line);
      if (defined $linesplit[3] && $linesplit[3] ne '') {
           push(@frequencies, $linesplit[3]);
      }
      if (defined $linesplit[4] && $linesplit[4] ne '') {
            push(@frequencies, $linesplit[4]);
      }
      if (defined $linesplit[5] && $linesplit[5] ne '') {
           push(@frequencies, $linesplit[5]);
      }
      
   }
   elsif($line =~/Zero-point correction\=\s+([-\w\.]*)/) { # searches for ZPE 
     $ZPEread = $1;
   }
   elsif($line =~ /zero-point Energies\=\s+([-\w\.]*)/) { # searches for ZPE + electronic energy
     $ZPEelectronic = $1;
   }
   elsif ($line =~ /Thermal correction to Enthalpy\=\s+([-\w\.]*)/) {
     $enthalpyread = $1;
   }
   elsif ($line =~ /Thermal correction to Gibbs Free Energy\=\s+([-\w\.]*)/) {
     $gibbsread = $1;
   }
   elsif($line =~ /thermal Free Energies\=\s+([-\w\.]*)/) { # searches for thermal free energy
     $thermalFreeEnergy = $1; 
     $thermalflag = 1;
   }
   elsif($line =~ /thermal Enthalpies\=\s+([-\w\.]*)/) { # searches for thermal enthalpy
      $thermalEnthalpy = $1;
   }
   elsif($line =~ / \<Sx\>\= [\w\.]* \<Sy\>\= [\w\.]* \<Sz\>\= [\w\.]* \<S\*\*2\>\= ([\w\.]*) S\= [\w\.]/ ) {
      $S_2 = $1;
   }
   elsif($line =~ /Charge\s*\=\s*[\-\w]*\s*Multiplicity\s*\=\s*(\w*)/ ){
      $S_2_ideal = ($1-1)/2*(($1-1)/2+1);
   }
}
close(INFILE);
print "Done reading ".$file."\n\n";

if ($thermalflag == 0) { die "Frequencies not found\n";}

$electronicEnergy = $ZPEelectronic - $ZPEread; # obtain electronic energy


{ no warnings 'uninitialized';
print "Before Low Frequency Corrections\n";
print "The electronic energy (Hartrees):          ".$electronicEnergy."\n";
print "The ZPE and Electronic E (Hartrees):       ".$ZPEelectronic."\n";
print "The Thermal Enthalpy (Hartrees):           ".$thermalEnthalpy."\n";
print "The Thermal Free Energy (Hartrees):        ".$thermalFreeEnergy."\n";
print "The S**2 value is:                         ".$S_2."\n".
      "with the ideal:                            ".$S_2_ideal."\n";
print "\n";

print "The Zero Point Corrections (Hartrees):     ".$ZPEread."\n";
print "Thermal correction to Enthalpy(Hartrees):  ".$enthalpyread."\n";
print "Thermal correction to Gibbs(Hartrees):     ".$gibbsread."\n";
print "\n";

} # end no warnings initialized

if ($TS_on eq 1) { # if a transition state calculation is not then, remove first frequency from array
    print "Frequency not corrected for TS optimization:\n";
    print "Frequency (cm**-1): ".$frequencies[0]."\n";
    shift(@frequencies);
}
#begin frequency replacements
print "Frequencies in need of correction: \n";

{ no warnings 'uninitialized';  # ignore unitialized variables, so it doesn't throw warnings in the output
for my $i (0 .. $#frequencies){   # see gaussian white pages for equations of entropy and vibrational computations
    if (($frequencies[$i] < $corrFreq) and ($frequencies[$i] > 0.0) ) {
       print "Frequency (cm**-1): ".$frequencies[$i]."\n";
       # compute corrections to entropy for low frequencies (most difference should be from this term)
       my $phi_div_T_old = $frequencies[$i]*(1/$kb)*(1/$T);
       my $phi_div_T_new = $corrFreq*(1/$kb)*(1/$T);
       my $S_v_old = $Rconst*( $phi_div_T_old / (exp($phi_div_T_old) - 1) - log(1 - exp( -$phi_div_T_old) ) );
       my $S_v_new = $Rconst*( $phi_div_T_new / (exp($phi_div_T_new) - 1) - log(1 - exp( -$phi_div_T_new) ) );
       my $S_corr = $S_v_new - $S_v_old;
       $entropycorr += $S_corr;

       # compute correction to ZPE for having low frequencies
       my $E_v_old = $Rconst * ( $frequencies[$i]*( 1/$kb) * ( 0.5 + 1/( exp($phi_div_T_old) - 1) ) );
       my $E_v_new = $Rconst * ( $corrFreq * (1/$kb) * ( 0.5 + 1/( exp($phi_div_T_new) - 1) ) );
       my $E_v_corr = $E_v_new - $E_v_old;
       $ZPE_corr += ( $Rconst * ( $corrFreq * (1/$kb) * (0.5) ) - ($Rconst * ( $frequencies[$i] * (1/$kb) * (0.5) ) ) ); 
       $Thermal_vib_corr += $E_v_corr;
    }
    elsif (($frequencies[$i] < $corrFreq) and ($frequencies[$i] < 0.0)  ){ #imaginary frequency corrections added here
       print "Frequency (cm**-1): ".$frequencies[$i]."  WARNING Imaginary Frequecy Found! Recommended further optimization. WARNING\n";
       # compute correction to entropy for imaginary freq 
       my $phi_div_T_new = $corrFreq*(1/$kb)*(1/$T);
       my $S_v_old = 0.0;
       my $S_v_new = $Rconst*( $phi_div_T_new / (exp($phi_div_T_new) - 1) - log(1 - exp( -$phi_div_T_new) ) );
       my $S_corr = $S_v_new - $S_v_old;
       $entropycorr += $S_corr;

       # compute correction to ZPE for having low frequencies
       my $E_v_old = 0.0;
       my $E_v_new = $Rconst * ( $corrFreq * (1/$kb) * ( 0.5 + 1/( exp($phi_div_T_new) - 1) ) );
       my $E_v_corr = $E_v_new - $E_v_old;
       $ZPE_corr += ( $Rconst * ( $corrFreq * (1/$kb) * (0.5) ) - ($Rconst * ( $frequencies[$i] * (1/$kb) * (0.5) ) ) );
       $Thermal_vib_corr += $E_v_corr;
       $imagflag = 1;
    }


}

# Format for output (fixed 5 decimal places)
$ZPE_corr = sprintf("%.5f",$ZPE_corr);
$Thermal_vib_corr = sprintf("%.5f",$Thermal_vib_corr);
$entropycorr = sprintf("%.5f",$entropycorr);

# compute the enthalpy and free energies
$enthalpy_total_corr = $thermalEnthalpy + ($Thermal_vib_corr / $hartreetokcal);
$gibbscorr = ($Thermal_vib_corr - $entropycorr*$T );

# Format numbers for output (fixed 6 and 5 decimal places)
$enthalpy_total_corr = sprintf("%.6f",$enthalpy_total_corr);
$gibbscorr = sprintf("%.5f",$gibbscorr);

print "All Frequencies Analyzed, Corrections at ".$T." K\n";
print "The magnitude of changes from low frequencies is the following:\n";
print "The low Freq ZPE Correction (kcal/mol):          ".$ZPE_corr."\n";
print "The Low Freq E_v Correction (kcal/mol):          ".$Thermal_vib_corr."\n";
print "The Low Freq Entropic Correction (kcal/mol*K):  ".$entropycorr."\n";
print "The Low Freq Free Energy Correction (kcal/mol):  ".$gibbscorr."\n";
print "\n";

# recompute ZPE with low freq corrections
my $ZPE = $ZPEread + ($ZPE_corr / $hartreetokcal);
$ZPE = sprintf("%.6f",$ZPE);
# recompute the total Gibbs "Correction"
$gibbs_total_corr = $thermalFreeEnergy + ($gibbscorr / $hartreetokcal );
$gibbs_total_corr = sprintf("%.6f",$gibbs_total_corr);
my $corrGibbsCont = $gibbs_total_corr - $electronicEnergy;
$corrGibbsCont = sprintf("%.6f",$corrGibbsCont);
#recompute the total internal thermal "correction"
my $corrThermalCont = $enthalpy_total_corr - $electronicEnergy;
$corrThermalCont = sprintf("%.6f",$corrThermalCont);

print "The Low Frequency Corrected Results:\n";
print "The electronic energy (Hartrees):                            ".$electronicEnergy."\n";
print "The Corrected Thermal Enthalpy (Hartrees):                   ".$enthalpy_total_corr."\n";
print "The Corrected Thermal Free Energy (Hartrees):                ".$gibbs_total_corr."\n\n";

print "The Corrected Zero Point Vibrational Energy (Hartrees):      ".$ZPE."\n";
print "The Corrected Thermal Enthalpy Contribution (Hartrees):      ".$corrThermalCont."\n";
print "The Corrected Thermal Free Energy Contribution (Hartrees):   ".$corrGibbsCont."\n";

if ($imagflag == 1) { print "WARNING IMAGINARY FREQUENCIES!!  \n "; }

print "\n \n"
} # end of section where it ignores undeclared variables


