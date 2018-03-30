#!/bin/bash

# Runs 0 ps traj for each desired mode to generate 
# DIPMOL_CMD, DIPIND_CMD, and POSITION_CMD files for use with MB-mu and MB-alpha

  # User defined parameters

  nmol=324				# number of water molecules in system
  natoms=$((3*${nmol}))			# number of atoms
  nlines=$((3*${nmol}+2))		# number of lines per frame in xyz files
  DLPOLY=/home/dmoberg/codes/dlpoly2-ttm/dlpoly_ttm_openmpi_cmd

  s=2000
#  s=2510	     `			# first mode of interest for analysis
#  s=1		     		# can be set to 1 if number of first mode # is not known
#  nmodes=1350       		# to test with small number first (2515 was first mode of interest in test)
  nmodes=$((3*${natoms}-6))  		# total number of normal modes

  cutoff=3000	     # sets cutoff frequency.  only modes with larger frequencies will be analyzed, use 3000 for analyzing water stretching region

  ###################################################################

  # Begin setup of normal mode folders

  rm -r freq* initial/

  ln -s ../../vibfreq.dat
  ln -s ../../VIBxyz.xyz
  ln -s ../../CONFIG.01

  head -4 CONFIG.01 > cell

  ../generate_OH_freq_list.sh ${nmol}

  # splits xyz file generated from DLPOLY into config0000, config0001, etc.
  split -d -l ${nlines} -a 4 VIBxyz.xyz config

  # creates new xyz files with displaced coordinates 
  for ((i=$s;i<=$nmodes;i++)); do
    paste config0000 config$i > disp_add$i
    tail -${natoms} disp_add$i | awk '{print $1, $2 + $6, $3 + $7, $4 + $8}' > disp$i
  done

  # set NMOLS in FIELD file
  cp ./files/field ./files/FIELD
  sed -i 's/NMOLS/'"$nmol"'/g' ./files/FIELD
 
  # creates M site file
  ./files/append-msite.pl $nmol > files/msite_$nmol

  # converts xyz file of initial config to CONFIG file, attaches M sites
  mkdir initial
  mv config0000 initial/
  cd initial/
  ../files/xyz-to-config.pl < config0000 > initial_config
  cat ../cell initial_config ../files/msite_$nmol > CONFIG.01
  cp ../files/CONTROL ../files/FIELD .
  cd ..

  # Begin generation and calculation of each normal mode folder
  freq=0
  count=$s

  #select only OH stretching region 
  echo "Generating directories for normal modes $s to $nmodes"
  for ((i=$s;i<=$nmodes;i++)); do
    freq=$( awk 'FNR == 2 {print $5}' config$i ) 
    # sets cutoff for 
    if (( $(echo "$freq > $cutoff" | bc -l) )); then
      mkdir freq_$i
      sed -i '1s/^/ \n/' disp$i
      sed -i '1s/^/'"$natoms"' \n/' disp$i
      cp disp$i freq_$i/
      cp files/* freq_$i/

      #converts all xyz files to CONFIG files w/ M sites
      cd freq_$i
      ./xyz-to-config.pl < disp$i > disp_config
      cat ../cell disp_config msite_$nmol > CONFIG.01
      cd ..
    else
      count=$((count++))
   fi
  done

  # clean up folder
  rm config* disp*
