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
#./submit_jobs.sh 2515 3234  # 360 molecules
#./submit_jobs.sh 2683 3450   # 384 molecules
./submit_jobs.sh 2263 2910  # 324 molecules
