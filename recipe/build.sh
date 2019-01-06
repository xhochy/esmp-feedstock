export ESMF_DIR=`pwd`"/esmf"
export ESMP_source="ESMP"
export ESMF_PTHREADS="OFF"
export ESMF_OS=`uname -s`

export ESMF_COMPILER="gfortran"
export ESMF_ABI="64"
if [ `uname` == Darwin ]; then
    export ESMF_OPENMP="OFF"
else
    export ESMF_OPENMP="ON"
fi

# OPENMPI bits would go it
export ESMF_COMM="mpiuni"

export ESMF_INSTALL=${PREFIX}
export ESMF_INSTALL_PREFIX=${PREFIX}

export ESMF_MOAB="OFF"
export ESMF_ARRAYLITE="TRUE"
chmod -Rv a+rx esmf/scripts/*
cd esmf
make  -j
make install
cd ../ESMP
export FILES=`find ../../../.. -name "e*.mk" | tail -n1 `
echo "ESMK FILES ${FILES}"
export ESMFMKFILE=`python -c "import sys,os;full = sys.argv[1]; pth2 = os.path.join('libO',full.split('libO')[1][1:]) ; print pth2" ${FILES}`
echo "ESMF_mkfile: ${ESMFMKFILE}"

if [ `uname` == Darwin ]; then
    cat > src/ESMP_Config.py << EOF
ESMFMKFILE = "libO/Darwin.gfortran.64.mpiuni.default/esmf.mk"
EOF

else
    ${PYTHON} generateESMP_Config.py
fi

cd ..
cp -rf ESMP ${SP_DIR}

if [ `uname` == Darwin ]; then 
    install_name_tool -id @rpath/libO/Darwin.gfortran.64.mpiuni.default/libesmf_fullylinked.dylib ${PREFIX}/lib/libO/Darwin.gfortran.64.mpiuni.default/libesmf_fullylinked.dylib
    install_name_tool -id @rpath/libO/Darwin.gfortran.64.mpiuni.default/libesmf.dylib ${PREFIX}/lib/libO/Darwin.gfortran.64.mpiuni.default/libesmf.dylib
fi

