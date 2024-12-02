# Sequence and protocols

The sequence, implemented for **Bruker Paravision PV-360: 3.5 & 3.6**, and the corresponding protocol for fully-sampled  is available in the folder  `MR sequence`. 

## Enable compressed-sensing acquisition

Compressed-sensing implementation is available through the standard Bruker tab `Resolution/Encoding`. If you want to perform a compressed-sensing experiment with an acceleration of 2 like the one used here : acceleration factor = 50% and use a calibration size of 5%
```
##$PVM_EncCSUndersampling=50
##$PVM_EncCSCenterRatio=5
```

## Source code

Source code is available in this private directory : [https://github.com/aTrotier/a\_MP2RAGE\_CS\_360](https://github.com/aTrotier/a_MP2RAGE_CS_360)

