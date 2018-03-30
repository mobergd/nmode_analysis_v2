#!/bin/bash

#PBS -N nmodes
#PBS -q glean
#PBS -l walltime=00:30:00,nodes=1:ppn=16
#PBS -e nmodes.error
#PBS -o nmodes.out
##PBS -M psharp@ucsd.edu
##PBS -m aben
#PBS -V

cd $PBS_O_WORKDIR

cd freqs/

DLPOLY=/home/dmoberg/codes/dlpoly2-ttm/dlpoly_ttm_openmpi_cmd

./add_disp.sh

cd initial/
mpirun -np 16 $DLPOLY
cd ../

cd split_runs/
###./submit_jobs.sh {9*Nwat-6 - 2*Nwat+1} {9*Nwat-6}
./submit_jobs.sh 2515 3234  # 360 molecules: Ih, XI, XV
#./submit_jobs.sh 2263 2910  # 324 molecules: IX
#./submit_jobs.sh 2683 3450  # 384 molecules: VIII
#./submit_jobs.sh 5287 6798  # 756 molecules: XIII
#./submit_jobs.sh 5371 6906  # 768 molecules: II
