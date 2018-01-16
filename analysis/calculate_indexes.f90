! Dan 09-25-17
! Program to calculate symmetry, antisymmetry, and localization
! indexes in ice systems.
!
! Input:
! VIBxyz.xyz file from DLPOLY vib (list of xyz files of initial config
!    and all normal mode displacement vectors)
!
! Execute as:
! ./calculate_indexes VIBxyz.xyz Nwats
!
! Output:
! sym.dat              -  sym indexes for each mode
! antisym.dat          -  antisym indexes for each mode
! localization.dat     -  local. indexes for each mode
! all_sym.dat          -  each oxygen's sym index in each mode
! all_antisym.dat      -  each oxygen's antisym index in each mode
! all_localization.dat -  each oxygen's local. index in each mode
! nmcoords.xyz         -  xyz files of all initial + nm displacements
! init.xyz             -  xyz file of initial config

program coords
 implicit none 

  character(len=300) :: file1,nwat,junk
  character(len=2),allocatable :: atomtyp(:)

  integer ::  nmodes,nmol_wat,natms,i,j,k

  real(kind=8),allocatable :: freq(:),init(:,:),nmcoord(:,:),nmdisp(:,:)
  real(kind=8),allocatable :: sym(:,:),asym(:,:),m(:,:)
  real(kind=8),allocatable :: sym_tot(:),asym_tot(:),m_tot(:)
 
  call getarg(1,file1)
  open(unit=1,file=file1,action='read')
 ! open(unit=1,file='OHconfs.xyz',action='read')

  call getarg(2,nwat)
  read(nwat,*) nmol_wat

  natms=3*nmol_wat
  nmodes=9*nmol_wat-6  ! for all modes
!  nmodes=2*nmol_wat   ! for only stretching modes

  allocate(freq(nmodes))

  allocate(atomtyp(natms))

  allocate(nmcoord(natms,3),nmdisp(natms,3),init(natms,3))

  allocate(sym(nmodes,nmol_wat),asym(nmodes,nmol_wat),m(nmodes,nmol_wat))
  allocate(sym_tot(nmodes),asym_tot(nmodes),m_tot(nmodes))

  open(unit=100,file='init.xyz',action='write')
  open(unit=101,file='nmcoords.xyz',action='write')
  open(unit=200,file='all_sym.dat',action='write')
  open(unit=201,file='all_antisym.dat',action='write')
  open(unit=202,file='all_localization.dat',action='write')
  open(unit=300,file='sym.dat',action='write')
  open(unit=301,file='antisym.dat',action='write')
  open(unit=302,file='localization.dat',action='write')


 do i=1,nmodes+1

    if (i==1) then
      read(1,*) junk
      read(1,*) junk, junk

      do j=1,natms
        read(1,*) atomtyp(j),init(j,:)
        write(100,'(3f20.12)') init(j,:)  ! to print out initial config file
      enddo
  
    else
      read(1,*) junk
      read(1,*) junk, junk, junk, junk, freq(i)

      do j=1,natms
        read(1,*) atomtyp(j),nmdisp(j,:)
        nmcoord(j,:)=init(j,:)+nmdisp(j,:)
        write(101,'(3f20.12)') nmcoord(j,:)
      enddo

      do j=1,nmol_wat
        k=3*(j-1)

        sym(i,j)=SQRT((nmcoord(k+1,1)-nmcoord(k+2,1))**2 + (nmcoord(k+1,2)-nmcoord(k+2,2))**2 + &
                      (nmcoord(k+1,3)-nmcoord(k+2,3))**2) &
                -SQRT((init(k+1,1)-init(k+2,1))**2 + (init(k+1,2)-init(k+2,2))**2 + (init(k+1,3)-init(k+2,3))**2) &
                +SQRT((nmcoord(k+1,1)-nmcoord(k+3,1))**2 + (nmcoord(k+1,2)-nmcoord(k+3,2))**2 + &
                      (nmcoord(k+1,3)-nmcoord(k+3,3))**2) &
                -SQRT((init(k+1,1)-init(k+3,1))**2 + (init(k+1,2)-init(k+3,2))**2 + &
                      (init(k+1,3)-init(k+3,3))**2)

         sym(i,j)=sym(i,j)/nmol_wat

         sym_tot(i)=sym_tot(i)+ABS(sym(i,j))

         asym(i,j)=(SQRT((nmcoord(k+1,1)-nmcoord(k+2,1))**2 + (nmcoord(k+1,2)-nmcoord(k+2,2))**2 + &
                         (nmcoord(k+1,3)-nmcoord(k+2,3))**2) &
                   -SQRT((init(k+1,1)-init(k+2,1))**2 + (init(k+1,2)-init(k+2,2))**2 + (init(k+1,3)-init(k+2,3))**2)) &
                   -(SQRT((nmcoord(k+1,1)-nmcoord(k+3,1))**2 + (nmcoord(k+1,2)-nmcoord(k+3,2))**2 + &
                          (nmcoord(k+1,3)-nmcoord(k+3,3))**2) &
                   -SQRT((init(k+1,1)-init(k+3,1))**2 + (init(k+1,2)-init(k+3,2))**2 + &
                         (init(k+1,3)-init(k+3,3))**2))

         asym(i,j)=asym(i,j)/nmol_wat

         asym_tot(i)=asym_tot(i)+ABS(asym(i,j))

         m(i,j)=(nmdisp(k+1,1)**2 + nmdisp(k+1,2)**2 + nmdisp(k+1,3)**2)

         m_tot(i)=m_tot(i)+m(i,j)

         write(200,'(2f20.12)') sym(i,j)
         write(201,'(2f20.12)') asym(i,j)
         write(202,'(2f20.12)') m(i,j)

      enddo

      m_tot(i)=MAXVAL(m(i,:))/m_tot(i)

    endif

 enddo

 do j=2,nmodes+1
   write(300,'(2f20.12)') freq(j),sym_tot(j)
   write(301,'(2f20.12)') freq(j),asym_tot(j)
   write(302,'(2f20.12)') freq(j),m_tot(j)
 enddo

end 
