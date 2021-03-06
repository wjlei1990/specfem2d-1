
!========================================================================
!
!                   S P E C F E M 2 D  Version 7 . 0
!                   --------------------------------
!
! Copyright CNRS, INRIA and University of Pau, France,
! and Princeton University / California Institute of Technology, USA.
! Contributors: Dimitri Komatitsch, dimitri DOT komatitsch aT univ-pau DOT fr
!               Nicolas Le Goff, nicolas DOT legoff aT univ-pau DOT fr
!               Roland Martin, roland DOT martin aT univ-pau DOT fr
!               Christina Morency, cmorency aT princeton DOT edu
!
! This software is a computer program whose purpose is to solve
! the two-dimensional viscoelastic anisotropic or poroelastic wave equation
! using a spectral-element method (SEM).
!
! This software is governed by the CeCILL license under French law and
! abiding by the rules of distribution of free software. You can use,
! modify and/or redistribute the software under the terms of the CeCILL
! license as circulated by CEA, CNRS and INRIA at the following URL
! "http://www.cecill.info".
!
! As a counterpart to the access to the source code and rights to copy,
! modify and redistribute granted by the license, users are provided only
! with a limited warranty and the software's author, the holder of the
! economic rights, and the successive licensors have only limited
! liability.
!
! In this respect, the user's attention is drawn to the risks associated
! with loading, using, modifying and/or developing or reproducing the
! software by the user in light of its specific status of free software,
! that may mean that it is complicated to manipulate, and that also
! therefore means that it is reserved for developers and experienced
! professionals having in-depth computer knowledge. Users are therefore
! encouraged to load and test the software's suitability as regards their
! requirements in conditions enabling the security of their systems and/or
! data to be ensured and, more generally, to use and operate it in the
! same conditions as regards security.
!
! The full text of the license is available in file "LICENSE".
!
!========================================================================

module source_file

  implicit none

  ! source parameters
  integer, dimension(:),pointer ::  source_type,time_function_type
  double precision, dimension(:),pointer :: xs,zs,f0,tshift_src,anglesource, &
    Mxx,Mzz,Mxz,factor
  logical, dimension(:),pointer ::  source_surf

contains

  subroutine read_source_file(NSOURCES)

! reads in source file DATA/SOURCE

  implicit none
  include "constants.h"

  integer :: NSOURCES

  ! local parameters
  integer :: ios,icounter,i_source,num_sources
  character(len=150) string_read
  integer, parameter :: IIN_SOURCE = 22

  ! allocates memory arrays
  allocate(source_surf(NSOURCES))
  allocate(xs(NSOURCES))
  allocate(zs(NSOURCES))
  allocate(source_type(NSOURCES))
  allocate(time_function_type(NSOURCES))
  allocate(f0(NSOURCES))
  allocate(tshift_src(NSOURCES))
  allocate(anglesource(NSOURCES))
  allocate(Mxx(NSOURCES))
  allocate(Mxz(NSOURCES))
  allocate(Mzz(NSOURCES))
  allocate(factor(NSOURCES))

  ! counts lines
  open(unit=IIN_SOURCE,file='DATA/SOURCE',iostat=ios,status='old',action='read')
  if(ios /= 0) stop 'error opening DATA/SOURCE file'

  icounter = 0
  do while(ios == 0)
     read(IIN_SOURCE,"(a)",iostat=ios) string_read

     if(ios == 0) then

! suppress trailing carriage return (ASCII code 13) if any (e.g. if input text file coming from Windows/DOS)
       if(index(string_read,achar(13)) > 0) string_read = string_read(1:index(string_read,achar(13))-1)

! suppress leading and trailing white spaces, if any
       string_read = adjustl(string_read)
       string_read = string_read(1:len_trim(string_read))

! if the line is not empty and is not a comment, count it
       if(len_trim(string_read) > 0 .and. (index(string_read,'#') == 0 .or. index(string_read,'#') > 1)) icounter = icounter + 1

     endif

  enddo
  close(IIN_SOURCE)

  ! checks counter
  if(mod(icounter,NLINES_PER_SOURCE) /= 0) &
    stop 'total number of non blank and non comment lines in SOURCE file should be a multiple of NLINES_PER_SOURCE'

  ! total number of sources
  num_sources = icounter / NLINES_PER_SOURCE

  if(num_sources < 1) stop 'need at least one source in SOURCE file'
  if(num_sources /= NSOURCES) &
       stop 'total number of sources read is different than declared in Par_file'

  ! reads in source parameters
  open(unit=IIN_SOURCE,file='DATA/SOURCE',status='old',action='read')
  do  i_source=1,NSOURCES
    call read_value_logical(IIN_SOURCE,IGNORE_JUNK,source_surf(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,xs(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,zs(i_source))
    call read_value_integer(IIN_SOURCE,IGNORE_JUNK,source_type(i_source))
    call read_value_integer(IIN_SOURCE,IGNORE_JUNK,time_function_type(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,f0(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,tshift_src(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,anglesource(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,Mxx(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,Mzz(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,Mxz(i_source))
    call read_value_double_precision(IIN_SOURCE,IGNORE_JUNK,factor(i_source))

    ! note: we will further process source info in solver,
    !         here we just read in the given specifics and show them

    print *
    print *,'Source', i_source
    print *,'Position xs, zs = ',xs(i_source),zs(i_source)
    print *,'Frequency, delay = ',f0(i_source),tshift_src(i_source)
    print *,'Source type (1=force, 2=explosion): ',source_type(i_source)
    print *,'Time function type (1=Ricker, 2=First derivative, 3=Gaussian, 4=Dirac, 5=Heaviside): ',time_function_type(i_source)
    print *,'Angle of the source if force = ',anglesource(i_source)
    print *,'Mxx of the source if moment tensor = ',Mxx(i_source)
    print *,'Mzz of the source if moment tensor = ',Mzz(i_source)
    print *,'Mxz of the source if moment tensor = ',Mxz(i_source)
    print *,'Multiplying factor = ',factor(i_source)
    print *
  enddo ! do i_source=1,NSOURCES
  close(IIN_SOURCE)

  end subroutine read_source_file

end module source_file

