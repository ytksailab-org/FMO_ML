#!/usr/bin/perl

use strict;
use warnings;

# usage:
# ./this_program Matsushita_PHBH.csv BLOSUM psf ssf seqlen > Matsushita_PHBH_BLOSUM_psf_ssf.csv
# seqlen = 4

our $RS = "/home/tmatsushita/resource/aafeat";
our $RS2 = "/home/saito-nig/work/160215_aiseq/data/Matsushita_PHBH/psf";
our $RS3 = "/home/saito-nig/work/160215_aiseq/data/Matsushita_PHBH/ssf";

# from [Westen et al, J Cheminform, 2013]
my %FeatFile = (
# BLOSUM.txt is extracted from Table 5 in [Georgiev, J Comput Biol, 2009], 
# which corresponds to features derived by eigenvalue decomposition of BLOSUM. 
# In [Westen et al, J Cheminform, 2013], they describe  
# > a descriptor set based on a VARIMAX analysis of physicochemical properties 
# > which were subsequently converted to indices based on the BLOSUM62
# which implies they use Table 7 in [Georgiev, J Comput Biol, 2009]. 
# However, by inspecting the supplementary file in [Westen et al, J Cheminform, 2013], 
# I realized that they actually used Table 5 rather than Table 7. 
"BLOSUM" => "$RS/BLOSUM.txt", 
"FASGAI" => "$RS/FASGAI.txt",
"MS-WHIM" => "$RS/MS-WHIM.txt",
"T-scale" => "$RS/T-scale.txt",
"ST-scale" => "$RS/ST-scale.txt",
"Z-scale" => "$RS/Z-scale.txt",
"VHSE" => "$RS/VHSE.txt",
# Features proposed in [Westen et al, J Cheminform, 2013]
"ProtFP" => "$RS/ProtFP.txt",
"ProtFP-Feature" => "$RS/ProtFP-Feature.txt",
"Aromaphilicity" => "$RS/Aromaphilicity.txt",
"KD-MJ-W-P" => "$RS/KD-MJ-W-P.txt",
);
# Position specific feature
my %PsfFile = (
"PSI-BLAST-200-5" => "$RS2/PSI-BLAST-200-5",
#"RMSF-all" => "$RS2/RMSF-all",
#"RMSF-local1" => "$RS2/RMSF-local1",
);
my %SsfFile = (
"bert-base-mean" => "$RS3/bert-base-mean.txt",
"bert-base-mean-new" => "$RS3/bert-base-mean-new.txt",
"bert-EV0.001-ML600-VL0.1-256-16-mean" => "$RS3/bert-EV0.001-ML600-VL0.1-256-16-mean.txt",
"bert-EV0.001-ML600-VL0.1-256-16-mean-new" => "$RS3/bert-EV0.001-ML600-VL0.1-256-16-mean-new.txt",
"bert-base-concat" => "$RS3/bert-base-concat.txt",
"bert-EV0.001-ML500-VL0.1-256-16-mean" => "$RS3/bert-EV0.001-ML500-VL0.1-256-16-mean.txt",
"bert-EV0.001-ML500-VL0.1-256-16-concat" => "$RS3/bert-EV0.001-ML500-VL0.1-256-16-concat.txt",
"bert-EV0.001-ML1024-VL0.1-256-16-mean" => "$RS3/bert-EV0.001-ML1024-VL0.1-256-16-mean.txt",
"bert-EV0.001-ML1024-VL0.1-256-16-concat" => "$RS3/bert-EV0.001-ML1024-VL0.1-256-16-concat.txt",
#"Contact-bit-local1-init" => "$RS3/Contact-bit-local1-init.txt",
#"Contact-MJ-local1-init" => "$RS3/Contact-MJ-local1-init.txt",
#"Contact-bit-all-init" => "$RS3/Contact-bit-all-init.txt",
#"Contact-MJ-all-init" => "$RS3/Contact-MJ-all-init.txt",
#"Contact-bit-local1-min" => "$RS3/Contact-bit-local1-min.txt",
#"Contact-MJ-local1-min" => "$RS3/Contact-MJ-local1-min.txt",
#"Contact-bit-all-min" => "$RS3/Contact-bit-all-min.txt",
#"Contact-MJ-all-min" => "$RS3/Contact-MJ-all-min.txt",
#"Contact-bit-local1-1ns" => "$RS3/Contact-bit-local1-1ns.txt",
#"Contact-MJ-local1-1ns" => "$RS3/Contact-MJ-local1-1ns.txt",
#"Contact-bit-all-1ns" => "$RS3/Contact-bit-all-1ns.txt",
#"Contact-MJ-all-1ns" => "$RS3/Contact-MJ-all-1ns.txt",
#"Contact-bit-local1-10ns" => "$RS3/Contact-bit-local1-10ns.txt",
#"Contact-MJ-local1-10ns" => "$RS3/Contact-MJ-local1-10ns.txt",
#"Contact-bit-all-10ns" => "$RS3/Contact-bit-all-10ns.txt",
#"Contact-MJ-all-10ns" => "$RS3/Contact-MJ-all-10ns.txt",
);

# $FeatValue->{"A"} = [0.01, -0.24, 0.35];
my $FeatValue = {};
# $PsfValue->[0]->{"A"} = [0.01, -0.24, 0.35];
my $PsfValue = [];
# $SsfValue->{"AMP"} = [0.01, -0.24, 0.35];
my $SsfValue = {};

my $InFile = shift(@ARGV);
my $SeqLen = pop(@ARGV);
my @FeatList = @ARGV;

&init_feat($FeatValue);
for (my $i=0; $i<@FeatList; $i++) {
    exists($FeatFile{$FeatList[$i]}) or next;
    &load_feat($FeatValue, $FeatFile{$FeatList[$i]});
    print STDERR "load feature $FeatFile{$FeatList[$i]}\n";
}
foreach my $aa (sort keys %$FeatValue) {
    my @feat = @{$FeatValue->{$aa}};
    print STDERR "$aa feature ", join(",", @feat), "\n";
}
&init_psf($PsfValue, $SeqLen);
for (my $i=0; $i<@FeatList; $i++) {
    exists($PsfFile{$FeatList[$i]}) or next;
    &load_psf($PsfValue, $SeqLen, $PsfFile{$FeatList[$i]});
    print STDERR "load psf $PsfFile{$FeatList[$i]}\n";
}
for (my $i=0; $i<$SeqLen; $i++) {
    foreach my $aa (sort keys %{$PsfValue->[$i]}) {
	my @psf = @{$PsfValue->[$i]->{$aa}};
	print STDERR "position $i $aa psf ", join(",", @psf), "\n";
    }
}
&init_ssf($SsfValue);
for (my $i=0; $i<@FeatList; $i++) {
    exists($SsfFile{$FeatList[$i]}) or next;
    &load_ssf($SsfValue, $SsfFile{$FeatList[$i]});
    print STDERR "load ssf $SsfFile{$FeatList[$i]}\n";
}
foreach my $ss (sort keys %$SsfValue) {
    my @feat = @{$SsfValue->{$ss}};
#    print STDERR "$ss feature ", join(",", @feat), "\n";
}


my $tbl;
my %hidx;

open(IN, $InFile) or die "cannot read $InFile\n";
while (my $line=<IN>) {
    chomp $line;
    my @cells = split(/\,/, $line);
    for (my $i=0; $i<@cells; $i++) {
	$cells[$i] =~ /^\"(.*)\"$/ and $cells[$i] = $1;
    }

    if (!%hidx) {
	for (my $i=0; $i<@cells; $i++) {
	    $hidx{$cells[$i]} = $i;
	    print STDERR "load header entry $cells[$i]\n";
	}
	next;
    }

    my $name; 
    my @feat;
    my @pred;
    $name = $cells[$hidx{"seq"}];
# replace amber stop codons
    push(@feat, &get_feat($cells[$hidx{"seq"}], $FeatValue, $PsfValue, $SsfValue, $SeqLen));
# transform scores
#    push(@pred, $cells[$hidx{"8hplc"}]);
#    push(@pred, $cells[$hidx{"8nadph"}]);
    push(@pred, $cells[$hidx{"22hplc"}]);
#    push(@pred, $cells[$hidx{"22nadph"}]);
#    push(@pred, $cells[$hidx{"compound21"}]);
#    push(@pred, $cells[$hidx{"compound8"}]);
#    push(@pred, $cells[$hidx{"compound14"}]);
#    push(@pred, $cells[$hidx{"compound16"}]);
#    push(@pred, $cells[$hidx{"compound22"}]);

    push(@$tbl, [$name, @feat, @pred]);
}
close(IN);


my @head;
my $multi=1;
push(@head, "seq");
for (my $i=0; $i<@{$tbl->[0]}-1-$multi; $i++) {
    push(@head, "f");
}
#push(@head, "8hplc");
#push(@head, "8nadph");
push(@head, "22hplc");
#push(@head, "22nadph");
#push(@head, "compound21");
#push(@head, "compound8");
#push(@head, "compound14");
#push(@head, "compound16");
#push(@head, "compound22");

print join(",", @head), "\n";
for (my $i=0; $i<@$tbl; $i++) {
    print join(",", @{$tbl->[$i]}), "\n";
}


sub init_feat {
    my ($FeatValue) = @_;
    foreach my $aa ("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V") {
	$FeatValue->{$aa} = [];
    }    
}
sub init_psf {
    my ($PsfValue, $SeqLen) = @_;
    for (my $i=0; $i<$SeqLen; $i++) {
	$PsfValue->[$i] = {};
	foreach my $aa ("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V") {
	    $PsfValue->[$i]->{$aa} = [];
	}
    }
}
sub init_ssf {
    my ($SsfValue) = @_;
}


sub load_feat {
    my ($FeatValue, $file) = @_;

    open(IN, $file) or die "cannot read $file\n";
    while (my $line=<IN>) {
	chomp $line;
	my @cells = split(/\t/, $line);
	my $aa = shift(@cells);
	my @feat = @cells;
	push(@{$FeatValue->{$aa}}, @feat);
    }
    close(IN);
}
sub load_psf {
    my ($PsfValue, $SeqLen, $file) = @_;

    for (my $i=0; $i<$SeqLen; $i++) {
	open(IN, "$file.$i.txt") or die "cannot read $file.$i.txt\n";
	while (my $line=<IN>) {
	    chomp $line;
	    my @cells = split(/\t/, $line);
	    my $aa = shift(@cells);
	    my @psf = @cells;
	    push(@{$PsfValue->[$i]->{$aa}}, @psf);
	}
	close(IN);
    }
}
sub load_ssf {
    my ($SsfValue, $file) = @_;

    open(IN, $file) or die "cannot read $file\n";
    while (my $line=<IN>) {
	chomp $line;
	my @cells = split(/\t/, $line);
	my $ss = shift(@cells);
	my @ssf = @cells;
	push(@{$SsfValue->{$ss}}, @ssf);
    }
    close(IN);
}


sub get_feat {
    my ($sequence, $FeatValue, $PsfValue, $SsfValue, $SeqLen) = @_;
    my @feat;

    length($sequence)==$SeqLen or die "wrong sequence length $sequence $SeqLen\n";

    for (my $i=0; $i<length($sequence); $i++) {
	my $aa = substr($sequence, $i, 1);
	push(@feat, @{$FeatValue->{$aa}});
	push(@feat, @{$PsfValue->[$i]->{$aa}});
    }
    if (%$SsfValue) {
	exists($SsfValue->{$sequence}) or die "unknown sequence $sequence\n";
	push(@feat, @{$SsfValue->{$sequence}});
    }

    return @feat;
}

sub sigmoid {
    my ($x) = @_;
    return 1.0 / (1.0 + exp(-$x));
}

sub Sigmoid_pred {
    my ($val) = @_;
    my $val_thsh = 1.0;
    my $pred = &sigmoid($val-$val_thsh);

    print STDERR "$val pred $pred\n";
    return $pred;
}

sub SigmoidProduct_pred {
    my ($val1, $val2) = @_;
    my ($val1_thsh, $val2_thsh) = (1.0, 1.0);
    my $pred = &sigmoid($val1-$val1_thsh) * &sigmoid($val2-$val2_thsh);

    print STDERR "$val1 $val2 pred $pred\n";
    return $pred;
}
