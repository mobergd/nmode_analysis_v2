#!/bin/bash

DLPOLY=/home/dmoberg/codes/dlpoly2-ttm/dlpoly_ttm_openmpi_cmd
MBMU=/home/dmoberg/codes/dipole_polarizability_fitting/src/infrared/bulk_dip
MBALPHA=/home/dmoberg/codes/dipole_polarizability_fitting/src/raman/bulk_pol

for i in `seq $1 1 $2`; do
  cd ../freq_$i
  $DLPOLY &
  PID$i=$!
  cd ../split_runs
done
wait $PID1 $PID2 $PID3 $PID4 $PID5 $PID6 $PID7 $PID8 $PID9 $PID10 $PID11 $PID12 $PID13 $PID14 $PID15 $PID16

for i in `seq $1 1 $2`; do
  cd ../freq_$i
  $MBMU POSITION_CMD DIPMOL_CMD DIPIND_CMD mb > dip_mb.dat &
  $MBALPHA POSITION_CMD mb > pol_mb.dat &
  cd ../split_runs
done
wait

