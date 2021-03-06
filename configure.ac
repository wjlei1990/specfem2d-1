dnl                                               -*- Autoconf -*-
dnl
dnl Process this file with autoconf to produce the 'configure' script:
dnl
dnl autoreconf -I m4
dnl
dnl You must have recent versions of Autoconf and Automake installed.


AC_PREREQ(2.61)
AC_INIT([Specfem 2D], [6.2.0], [jtromp AT princeton.edu], [Specfem2D])
AC_CONFIG_SRCDIR([README])
AC_CONFIG_HEADER([setup/config.h])
AC_CONFIG_MACRO_DIR([m4])


# 'configure' options

AC_ARG_WITH([pyre],
    [AC_HELP_STRING([--with-pyre],
        [build Pyrized version @<:@default=no@:>@])],
    [want_pyre="$withval"],
    [want_pyre=no])
AM_CONDITIONAL([COND_PYRE], [test "$want_pyre" = yes])

AC_ARG_WITH([mpi],
    [AC_HELP_STRING([--with-mpi],
        [build parallel version @<:@default=yes@:>@])],
    [want_mpi="$withval"],
    [want_mpi=no])
AM_CONDITIONAL([COND_MPI], [test "$want_mpi" = yes])

AC_ARG_ENABLE([double-precision],
    [AC_HELP_STRING([--enable-double-precision],
        [solver in double precision @<:@default=no@:>@])],
    [want_double_precision="$enableval"],
    [want_double_precision=no])
if test "$want_double_precision" = no; then
    CUSTOM_REAL=SIZE_REAL
    CUSTOM_MPI_TYPE=MPI_REAL
else
    CUSTOM_REAL=SIZE_DOUBLE
    CUSTOM_MPI_TYPE=MPI_DOUBLE_PRECISION
fi
AC_SUBST([CUSTOM_REAL])
AC_SUBST([CUSTOM_MPI_TYPE])


# Checks for programs.

if test "$want_pyre" = yes; then
    AM_PATH_PYTHON([2.3])
    CIT_PYTHON_SYSCONFIG
fi

# a courtesy to the installed base of users
if test x"$FC" = x && test x"$F90" != x; then
    FC="$F90"
fi
if test x"$MPIFC" = x && test x"$MPIF90" != x; then
    MPIFC="$MPIF90"
fi

AC_PROG_FC
export FC
export MPIFC
F77="$FC"
FFLAGS="$FCFLAGS"
AC_PROVIDE([AC_PROG_F77])
AC_SUBST([FCENV])

flags_guess="$SHELL flags.guess"
AC_MSG_NOTICE([running $flags_guess])
flags=`$flags_guess` ||
    AC_MSG_ERROR([$flags_guess failed])
eval $flags

AC_FC_WRAPPERS
AC_LANG(Fortran)
AC_FC_SRCEXT(f90)
AC_FC_FREEFORM()
CIT_FC_PP_DEFINE()
AC_SUBST([FC_DEFINE])

AC_PROG_CC

AC_LANG_PUSH(C)
AC_CHECK_HEADER(emmintrin.h,AC_DEFINE([HAVE_EMMINTRIN],[1],[Define if emmintrin.h]))
AC_CHECK_HEADER(xmmintrin.h,AC_DEFINE([HAVE_XMMINTRIN],[1],[Define if xmmintrin.h]))
AC_LANG_POP(C)

#checks for Scotch

export SCOTCH_DIR
export SCOTCH_LIBDIR
export SCOTCH_INCLUDEDIR
export USE_BUNDLED_SCOTCH

AC_ARG_WITH([scotch-dir],
AC_HELP_STRING([--with-scotch-dir],[define the root path to Scotch (e.g. /opt/scotch/)]),
[
 ac_scotch_dir="$withval";
])

AC_ARG_WITH([scotch-includedir],
AC_HELP_STRING([--with-scotch-includedir],[define the path to the Scotch headers (e.g. /opt/scotch/include)]),
[
 ac_scotch_include_dir="$withval";
])

AC_ARG_WITH([scotch-libdir],
AC_HELP_STRING([--with-scotch-libdir],[define the path to the Scotch libraries (e.g. /opt/scotch/lib)]),
[
 ac_scotch_lib_dir="$withval";
])

if test "${USE_BUNDLED_SCOTCH}" != "1"; then

#daniel: scotch will be needed in directory src/meshfem2D/
  builddir=`pwd`
  cd src/meshfem2D/

  if test -z "${ac_scotch_lib_dir}"; then
    if test -n "${ac_scotch_dir}"; then
        ac_scotch_lib_dir="${ac_scotch_dir}/lib";
    else
        ac_scotch_lib_dir="/usr/lib";
    fi
  fi

  if test -z "${ac_scotch_include_dir}"; then
    if test -n "${ac_scotch_dir}"; then
      ac_scotch_include_dir="${ac_scotch_dir}/include";
    else
      ac_scotch_include_dir="/usr/include/scotch";
    fi
  fi

  scotch_lib=""
  ac_save_ldflags=${LDFLAGS}
  if test -n "${ac_scotch_lib_dir}"; then
    LDFLAGS="${LDFLAGS} -L${ac_scotch_lib_dir}";
  fi
  AC_CHECK_LIB(scotch,scotchfarchinit ,[scotch_lib="yes";],[scotch_lib="no";LDFLAGS=${ac_save_ldflags}], -lscotcherr)

  scotch_include=""
  ac_save_cppflags=${CPPFLAGS}
  # scotch only needed for fortran code
  #if test -n "${ac_scotch_include_dir}"; then
  #  CPPFLAGS="${CPPFLAGS} -I${ac_scotch_include_dir}";
  #fi

dnl This does not work because we are in Fortran mode, which does not
dnl handle headers.
dnl
dnl AC_CHECK_HEADER(scotchf.h,[scotch_include="yes";],[scotch_include="no";CPPFLAGS=${ac_save_cppflags}])

  scotch_usable="${scotch_lib}"

  # back to root directory
  cd $builddir

fi

AC_MSG_CHECKING([whether Scotch is usable])
if test "x${scotch_usable}" = "xyes"; then
 AC_DEFINE([HAVE_SCOTCH],[1],[defined if Scotch is installed])
 USE_BUNDLED_SCOTCH=0
 SCOTCH_DIR="${ac_scotch_dir}"
 SCOTCH_LIBDIR="${ac_scotch_lib_dir}"
 SCOTCH_INCLUDEDIR="${ac_scotch_include_dir}"
 AC_MSG_RESULT([yes])
else
 AC_DEFINE([HAVE_SCOTCH],[1],[defined if Scotch is installed])
 AC_MSG_RESULT([no, using bundled scotch instead])
 AC_PROG_LEX
 if test -z "$LEX" || test "X$LEX" = "Xno"; then
   AC_MSG_ERROR([No suitable lex found])
 fi
 AC_PROG_YACC
 if test -z "$YACC" || test "X$YACC" = "Xno"; then
   AC_MSG_ERROR([No suitable yacc or bison found])
 fi

 # scotch only needed with mpi support
 if test "$want_mpi" = yes; then

 #daniel: scotch bundle
 # uses bundled scotch: current version 5.1.12b
 USE_BUNDLED_SCOTCH=1

 SCOTCH_DIR="scotch_5.1.12b"
 SCOTCH_LIBDIR="${SCOTCH_DIR}/lib"
 SCOTCH_INCLUDEDIR="${SCOTCH_DIR}/include"

 # the following modifies the default scotch Makefile such that the package
 # will only be compiled once (no recompilation) when calling make
 #
 builddir=`pwd`
 cd src/meshfem2D/

 if test ! -f "${SCOTCH_DIR}/src/scotch/Makefile.org"; then

  # no Makefile backup files yet
  # modifies Makefiles once

  # creates backup copies of original Makefiles
  # src/scotch/
  cp ${SCOTCH_DIR}/src/scotch/Makefile ${SCOTCH_DIR}/src/scotch/Makefile.org
  # src/libscotch/
  cp ${SCOTCH_DIR}/src/libscotch/Makefile ${SCOTCH_DIR}/src/libscotch/Makefile.org
  # src/libscotchmetis/
  cp ${SCOTCH_DIR}/src/libscotchmetis/Makefile ${SCOTCH_DIR}/src/libscotchmetis/Makefile.org

 fi

  # replacement text in the default scotch Makefiles
  cat > conftmp.scotch.cmd <<_ACEOF
# scotch replacement text for install line
\$(bindir)/acpl\$(EXE): acpl\$(EXE)
	-\$(CP) acpl\$(EXE) \$(bindir)/acpl\$(EXE)
\$(bindir)/amk_ccc\$(EXE): amk_ccc\$(EXE)
	-\$(CP) amk_ccc\$(EXE) \$(bindir)/amk_ccc\$(EXE)
\$(bindir)/amk_fft2\$(EXE): amk_fft2\$(EXE)
	-\$(CP) amk_fft2\$(EXE) \$(bindir)/amk_fft2\$(EXE)
\$(bindir)/amk_grf\$(EXE): amk_grf\$(EXE)
	-\$(CP) amk_grf\$(EXE) \$(bindir)/amk_grf\$(EXE)
\$(bindir)/amk_hy\$(EXE): amk_hy\$(EXE)
	-\$(CP) amk_hy\$(EXE) \$(bindir)/amk_hy\$(EXE)
\$(bindir)/amk_m2\$(EXE): amk_m2\$(EXE)
	-\$(CP) amk_m2\$(EXE) \$(bindir)/amk_m2\$(EXE)
\$(bindir)/amk_p2\$(EXE): amk_p2\$(EXE)
	-\$(CP) amk_p2\$(EXE) \$(bindir)/amk_p2\$(EXE)
\$(bindir)/atst\$(EXE): atst\$(EXE)
	-\$(CP) atst\$(EXE) \$(bindir)/atst\$(EXE)
\$(bindir)/gbase\$(EXE): gbase\$(EXE)
	-\$(CP) gbase\$(EXE) \$(bindir)/gbase\$(EXE)
\$(bindir)/gcv\$(EXE): gcv\$(EXE)
	-\$(CP) gcv\$(EXE) \$(bindir)/gcv\$(EXE)
\$(bindir)/gmap\$(EXE): gmap\$(EXE)
	-\$(CP) gmap\$(EXE) \$(bindir)/gmap\$(EXE)
\$(bindir)/gmk_hy\$(EXE): gmk_hy\$(EXE)
	-\$(CP) gmk_hy\$(EXE) \$(bindir)/gmk_hy\$(EXE)
\$(bindir)/gmk_m2\$(EXE): gmk_m2\$(EXE)
	-\$(CP) gmk_m2\$(EXE) \$(bindir)/gmk_m2\$(EXE)
\$(bindir)/gmk_m3\$(EXE): gmk_m3\$(EXE)
	-\$(CP) gmk_m3\$(EXE) \$(bindir)/gmk_m3\$(EXE)
\$(bindir)/gmk_msh\$(EXE): gmk_msh\$(EXE)
	-\$(CP) gmk_msh\$(EXE) \$(bindir)/gmk_msh\$(EXE)
\$(bindir)/gmk_ub2\$(EXE): gmk_ub2\$(EXE)
	-\$(CP) gmk_ub2\$(EXE) \$(bindir)/gmk_ub2\$(EXE)
\$(bindir)/gmtst\$(EXE): gmtst\$(EXE)
	-\$(CP) gmtst\$(EXE) \$(bindir)/gmtst\$(EXE)
\$(bindir)/gord\$(EXE): gord\$(EXE)
	-\$(CP) gord\$(EXE) \$(bindir)/gord\$(EXE)
\$(bindir)/gotst\$(EXE): gotst\$(EXE)
	-\$(CP) gotst\$(EXE) \$(bindir)/gotst\$(EXE)
\$(bindir)/gout\$(EXE): gout\$(EXE)
	-\$(CP) gout\$(EXE) \$(bindir)/gout\$(EXE)
\$(bindir)/gpart\$(EXE): \$(bindir)/gmap\$(EXE)
	-\$(RM) \$(bindir)/gpart\$(EXE)
	-\$(LN) \$(bindir)/gmap\$(EXE) \$(bindir)/gpart\$(EXE)
\$(bindir)/gscat\$(EXE): gscat\$(EXE)
	-\$(CP) gscat\$(EXE) \$(bindir)/gscat\$(EXE)
\$(bindir)/gtst\$(EXE): gtst\$(EXE)
	-\$(CP) gtst\$(EXE) \$(bindir)/gtst\$(EXE)
\$(bindir)/mcv\$(EXE): mcv\$(EXE)
	-\$(CP) mcv\$(EXE) \$(bindir)/mcv\$(EXE)
\$(bindir)/mmk_m2\$(EXE): mmk_m2\$(EXE)
	-\$(CP) mmk_m2\$(EXE) \$(bindir)/mmk_m2\$(EXE)
\$(bindir)/mmk_m3\$(EXE): mmk_m3\$(EXE)
	-\$(CP) mmk_m3\$(EXE) \$(bindir)/mmk_m3\$(EXE)
\$(bindir)/mord\$(EXE): mord\$(EXE)
	-\$(CP) mord\$(EXE) \$(bindir)/mord\$(EXE)
\$(bindir)/mtst\$(EXE): mtst\$(EXE)
	-\$(CP) mtst\$(EXE) \$(bindir)/mtst\$(EXE)


install				: \$(bindir)/acpl\$(EXE) \$(bindir)/amk_ccc\$(EXE) \\
	\$(bindir)/amk_fft2\$(EXE) \$(bindir)/amk_grf\$(EXE) \\
	\$(bindir)/amk_hy\$(EXE) \$(bindir)/amk_m2\$(EXE) \\
	\$(bindir)/amk_p2\$(EXE) \$(bindir)/atst\$(EXE) \\
	\$(bindir)/gbase\$(EXE) \$(bindir)/gcv\$(EXE) \\
	\$(bindir)/gmap\$(EXE) \$(bindir)/gmk_hy\$(EXE) \\
	\$(bindir)/gmk_m2\$(EXE) \$(bindir)/gmk_m3\$(EXE) \\
	\$(bindir)/gmk_msh\$(EXE) \$(bindir)/gmk_ub2\$(EXE) \\
	\$(bindir)/gmtst\$(EXE) \$(bindir)/gord\$(EXE) \\
	\$(bindir)/gotst\$(EXE) \$(bindir)/gout\$(EXE) \\
	\$(bindir)/gpart\$(EXE) \$(bindir)/gscat\$(EXE) \\
	\$(bindir)/gtst\$(EXE) \$(bindir)/mcv\$(EXE) \\
	\$(bindir)/mmk_m2\$(EXE) \$(bindir)/mmk_m3\$(EXE) \\
	\$(bindir)/mord\$(EXE) \$(bindir)/mtst\$(EXE)

_ACEOF

  # avoids lines between 98 to 101, containing install lines, and replaces them
  awk '{if(NR<98)print $0}' ${SCOTCH_DIR}/src/scotch/Makefile.org > ${SCOTCH_DIR}/src/scotch/Makefile
  cat conftmp.scotch.cmd >> ${SCOTCH_DIR}/src/scotch/Makefile
  awk '{if(NR>101)print $0}' ${SCOTCH_DIR}/src/scotch/Makefile.org >> ${SCOTCH_DIR}/src/scotch/Makefile
  rm -f conftmp.scotch.cmd

  # replacement text in the default libscotch Makefile
  cat > conftmp.libscotch.cmd <<_ACEOF
# libscotch replacement text for install line
\$(libdir)/libscotch\$(LIB): libscotch\$(LIB)
	-\$(CP) libscotch\$(LIB) \$(libdir)
\$(libdir)/libscotcherr\$(LIB): libscotcherr\$(LIB)
	-\$(CP) libscotcherr\$(LIB) \$(libdir)
\$(libdir)/libscotcherrexit\$(LIB): libscotcherrexit\$(LIB)
	-\$(CP) libscotcherrexit\$(LIB) \$(libdir)
\$(includedir)/scotch.h: scotch.h
	-\$(CP) scotch.h \$(includedir)
\$(includedir)/scotchf.h: scotchf.h
	-\$(CP) scotchf.h \$(includedir)

install				: \$(libdir)/libscotch\$(LIB) \$(libdir)/libscotcherr\$(LIB) \\
	\$(libdir)/libscotcherrexit\$(LIB)	\\
	\$(includedir)/scotch.h \$(includedir)/scotchf.h

_ACEOF

  # avoids lines between 71 to 73, containing install lines, and replaces them
  awk '{if(NR<71)print $0}' ${SCOTCH_DIR}/src/libscotch/Makefile.org > ${SCOTCH_DIR}/src/libscotch/Makefile
  cat conftmp.libscotch.cmd >> ${SCOTCH_DIR}/src/libscotch/Makefile
  awk '{if(NR>73)print $0}' ${SCOTCH_DIR}/src/libscotch/Makefile.org >> ${SCOTCH_DIR}/src/libscotch/Makefile
  rm -f conftmp.libscotch.cmd

  # replaces single scotch line in Makefiles
  # src/scotch/
  sed "s/^scotch.*clean/scotch     : /" ${SCOTCH_DIR}/src/scotch/Makefile > conftmp.libscotch.mk
  mv conftmp.libscotch.mk ${SCOTCH_DIR}/src/scotch/Makefile
  # src/libscotch/
  sed "s/^scotch.*clean/scotch     : /" ${SCOTCH_DIR}/src/libscotch/Makefile > conftmp.libscotch.mk
  mv conftmp.libscotch.mk ${SCOTCH_DIR}/src/libscotch/Makefile
  # src/libscotchmetis/
  sed "s/^scotch.*clean/scotch     : /" ${SCOTCH_DIR}/src/libscotchmetis/Makefile > conftmp.libscotch.mk
  mv conftmp.libscotch.mk ${SCOTCH_DIR}/src/libscotchmetis/Makefile

 cd $builddir

 # done scotch Makefile modification

 else

 # no mpi support, scotch not needed
 USE_BUNDLED_SCOTCH=0

 fi # want_mpi


fi
LDFLAGS=${ac_save_ldflags}

# influential environment variables

AC_ARG_VAR(USE_BUNDLED_SCOTCH, [Set to 1 to always use the bundled Scotch library])
AC_ARG_VAR(SCOTCH_DIR, [Directory where Scotch is installed])
AC_ARG_VAR(SCOTCH_INCLUDEDIR, [Directory where Scotch headers are installed])
AC_ARG_VAR(SCOTCH_LIBDIR, [Directory where Scotch libraries are installed])
AC_ARG_VAR(MPIFC, [MPI Fortran compiler command])
AC_ARG_VAR(MPILIBS, [extra libraries for linking MPI programs])
AC_ARG_VAR(MPICC, [MPI C compiler command])
AC_ARG_VAR(FLAGS_CHECK, [Fortran compiler flags])
if test x"$MPIFC" = x; then
    MPIFC=mpif90
fi
if test x"$MPICC" = x; then
    MPICC=mpicc
fi

AC_ARG_VAR(LOCAL_PATH_IS_ALSO_GLOBAL, [files on a local path on each node are also seen as global with same path @<:@default=true@:>@])
if test x"$LOCAL_PATH_IS_ALSO_GLOBAL" = x; then
    LOCAL_PATH_IS_ALSO_GLOBAL=true
fi

AC_ARG_VAR(PYTHON, [Python interpreter])
AC_ARG_VAR(PYTHONPATH, [Python module search path])



# Checks for Python modules and packages.

AC_LANG(C)
if test "$want_pyre" = yes; then
    builddir=`pwd`
    save_PYTHONPATH="$PYTHONPATH"
    PYTHONPATH="$builddir/python:$PYTHONPATH"; export PYTHONPATH
    # Cheap work-around for the inability of merlin/setuptools to control #! line.
    rm -f pyspecfem2D
    $as_ln_s $PYTHON pyspecfem2D
    pyspecfem2D="$builddir/pyspecfem2D"
    cd $srcdir

    AC_MSG_NOTICE([downloading missing Python dependencies])
    AS_IF([AC_TRY_COMMAND([$pyspecfem2D setup.py install_deps -zmxd $builddir/deps >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD])],
          [],
          [AC_MSG_FAILURE([cannot download missing Python dependencies])])

    AC_MSG_NOTICE([building Python dependencies])
    AS_IF([AC_TRY_COMMAND([$pyspecfem2D setup.py develop -H None -f $builddir/deps -s $builddir -d $builddir/python >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD])],
          [],
          [AC_MSG_FAILURE([building Python dependencies])])

    AC_MSG_CHECKING([for egg-related flags])
    AS_IF([AC_TRY_COMMAND([$pyspecfem2D setup.py egg_flags >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD])],
          [AC_MSG_RESULT(ok)
           . egg-flags.sh
           rm -f egg-flags.sh
          ],
          [AC_MSG_RESULT(failed)
          AC_MSG_FAILURE([cannot scan Python eggs for flags])])

    cd $builddir
    rm -f pyspecfem2D
    PYTHONPATH="$save_PYTHONPATH"
    PYTHONPATH="${pythondir}:${pyexecdir}${save_PYTHONPATH:+:${save_PYTHONPATH}}"

    AC_SUBST(PYTHONPATH)
    AC_SUBST(PYTHON_EGG_CFLAGS)
    AC_SUBST(PYTHON_EGG_CPPFLAGS)
    AC_SUBST(PYTHON_EGG_LDFLAGS)
fi


# Checks for libraries.


# Checks for header files.

if test "$want_mpi" = yes; then
    CIT_FC_MPI_MODULE([mpif.h], [$MPIFC], [$FLAGS_CHECK], [], [
        AC_MSG_FAILURE([cannot compile a trivial MPI program using $MPIFC])
    ])
fi

# Checks for typedefs, structures, and compiler characteristics.

if test "$want_pyre" = yes; then
    CIT_FC_MAIN
fi


# Checks for library functions.


AC_CONFIG_FILES([
	Makefile
	src/meshfem2D/Makefile
	src/specfem2D/Makefile
	setup/constants.h
	setup/precision.h
	src/meshfem2D/scotch_5.1.12b/src/Makefile.inc
])
AC_OUTPUT


dnl end of configure.ac
