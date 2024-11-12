#---------------------------------------------------------
# # [Simple reconstruction](@id 01-simple_reconstruction)
#---------------------------------------------------------

# ## Description
# 
# This example describes how to perform a reconstruction of a fully acquisition acquired with the a_MP2RAGE_CS_360 sequence.
#

# ## Loading Package
using LazyArtifacts # loading data
using SEQ_BRUKER_a_MP2RAGE_CS_360
using CairoMakie # plotting

# ## Download the datasets
# if you run the literate example offline change the following line by : `MP2_artifacts = artifact"MP2RAGE_data"
datadir = Main.MP2_artifacts
@info "The test data is located at $datadir."

# If you want to perform your own reconstruction, you can change the following line in order to point to another a bruker dataset
path_bruker = joinpath(datadir, "MP2RAGE_FULLY")

# ## Perform the reconstruction 
# this function will perform a standard reconstruction without compressed-sensing. If your data are subsampled it will result in subsampling artifacts (blurring + noise-like)
#
# the keyword mean_NR=true will average the images accross the number of repetition dimension before performing the MP2RAGE/T1 maps estimation.
# Otherwise an image/T₁ map will be generated for each Number Of Repetition (NR)
d = reconstruction_MP2RAGE(path_bruker; mean_NR=true)


# the result is a dictionnary with the following fields :
# - "im_reco" : (x,y,z,Number of Channel , Number of Repetition,TI) Complex
# - "MP2RAGE" : (x,y,z,Number of Channel , Number of Repetition) Float
# - "T1map" : (x,y,z,Number of Channel , Number of Repetition) Float
# - "params_prot"
# - "params_reco"
# - "params_MP2RAGE"
# 
# im_reco corresponds to the TI₁ and TI₂ images in the complex format with 6 dimensions :
# (x,y,z, Number of Channel , Number of Repetition,TI)


# We can check the results

begin
  f = Figure(size=(500,400))
  ax=Axis(f[1,1],title="TI₁")
  h=heatmap!(ax,abs.(d["im_reco"][:,:,60,1,1,1]),colormap=:grays)

  ax=Axis(f[1,2],title="TI₂")
  h=heatmap!(ax,abs.(d["im_reco"][:,:,60,1,1,2]),colormap=:grays)

  ax=Axis(f[2,1],title="UNIT1 / MP2RAGE")
  h=heatmap!(ax,d["MP2RAGE"][:,:,60,1,1],colormap=:grays)

  ax=Axis(f[2,2],title="T₁ map")
  h=heatmap!(ax,d["T1map"][:,:,60,1,1],colorrange = (500,2000))

  for ax in f.content   # hide decoration befor adding colorbar
    hidedecorations!(ax)
  end

  Colorbar(f[2,3],h,label = "T₁ [ms]", flip_vertical_label=true)
  f
end

# The Lookup table used for the reconstruction is stored in the dictionnary (LUT).
# First dimension is the range of T1 and the 2nd is the expected value of the MP2RAGE signal between -0.5 to 0.5.
f=Figure()
ax = Axis(f[1,1],xlabel="T₁ [ms]")
lines!(ax,d["LUT"])
f

# ## Write results in BIDS format
# Results can be written following most of the [qBIDS format recommandation](https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html)

subject_name = "sub_01"
dir_path = "" # directory path where the files will be create
write_bids_MP2RAGE(d,subject_name,dir_path)

#=
which results in :
```
sub_01/
├─ MP2RAGE.json
└─ anat/
   ├─ sub_01_T1map.nii.gz
   ├─ sub_01_UNIT1.nii.gz
   ├─ sub_01_inv-1-complex_MP2RAGE.nii.gz
   ├─ sub_01_inv-1-mag_MP2RAGE.nii.gz
   ├─ sub_01_inv-1-phase_MP2RAGE.nii.gz
   ├─ sub_01_inv-2-complex_MP2RAGE.nii.gz
   ├─ sub_01_inv-2-mag_MP2RAGE.nii.gz
   └─ sub_01_inv-2-phase_MP2RAGE.nii.gz
```

For simplicity the T₁ map is stored in the anat/ folder like the ones created by Siemens.

If you want to generate the T1 map with another tool like qMRLab
the required MP2RAGE parameters are stored in the **MP2RAGE.json** file. In that case the data are supposed to be stored in a derivatives folder (see[qBIDS format recommandation](https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html))
=#

