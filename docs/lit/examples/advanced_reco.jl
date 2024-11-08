#---------------------------------------------------------
# # [Compressed-sensing reconstruction](@id 02-CS_reconstruction)
#---------------------------------------------------------

# ## Description
# 
# This example describes how to perform a compressed-sensingreconstruction of a CS-2 accelerated acquisition.

# ## Loading Package
using LazyArtifacts # loading data
using SEQ_BRUKER_a_MP2RAGE_CS_360
using CairoMakie # plotting

# In addition we load the package internally used to perform the reconstruction



# ## Loading Package
using Artifacts
using LazyArtifacts # loading data
using SEQ_BRUKER_a_MP2RAGE_CS_360
using CairoMakie # plotting

artifact_data = """
[MP2RAGE_data]
git-tree-sha1 = "04cd4c29bb9e2aeb5384fbc70a9af0e1a37ca369"
lazy = true

    [[MP2RAGE_data.download]]
    sha256 = "1f1b703c79db66ba6ef620651eca431cb0319d87f1eafa53826cb11a93afe4a8"
    url = "https://zenodo.org/records/14051522/files/data.tar.gz"
"""
# ## Download the datasets
temp_artifact_toml = tempname()
open(temp_artifact_toml, "w") do file
    write(file, artifact_data)
end
_hash = artifact_hash("MP2RAGE_data", temp_artifact_toml)
datadir = artifact_path(_hash)

@info "The test data is located at $datadir."

# If you want to perform your own reconstruction, you can change the following line in order to point to another a bruker dataset
path_bruker = joinpath(datadir, "MP2RAGE_CS2")

# ## Compressed-sensing reconstruction
# In order to use an advanced reconstruction we will pass some parameters that will be used by the reconstruction package MRIReco.jl
using SEQ_BRUKER_a_MP2RAGE_CS_360.MRIReco
using SEQ_BRUKER_a_MP2RAGE_CS_360.MRIReco.RegularizedLeastSquares

# We have to create a parameter dictionnary that will be used. If you need more information about it take a look at [MRIReco.jl](https://github.com/MagneticResonanceImaging/MRIReco.jl)

CS = Dict{Symbol,Any}()
CS[:sparseTrafo] = "Wavelet" #sparse trafo
CS[:reg] = L1Regularization(100.)       # regularization
CS[:solver] = FISTA    # solver
CS[:iterations] = 30

d = reconstruction_MP2RAGE(path_bruker; mean_NR=true,paramsCS = CS)

# for comparison purpose let's perform the undersampled reconstruction (without the paramCS keyword)
d_under = reconstruction_MP2RAGE(path_bruker; mean_NR=true)


# We can check the results

begin
  f = Figure(size=(500,400))
  ax=Axis(f[1,1],title="TI₁ undersampled")
  h=heatmap!(ax,abs.(d_under["im_reco"][:,:,60,1,1,1]),colormap=:grays)

  ax=Axis(f[1,2],title="TI₁ CS")
  h=heatmap!(ax,abs.(d["im_reco"][:,:,60,1,1,1]),colormap=:grays)


  ax=Axis(f[2,1],title="UNIT1 undersampled")
  h=heatmap!(ax,d_under["T1map"][:,:,60,1,1],colorrange = (500,2000))

  ax=Axis(f[2,2],title="UNIT1 CS")
  h=heatmap!(ax,d["T1map"][:,:,60,1,1],colorrange = (500,2000))

  for ax in f.content   # hide decoration befor adding colorbar
    hidedecorations!(ax)
  end

  Colorbar(f[2,3],h,label = "T₁ [ms]", flip_vertical_label=true)
  f
end



# ## Write results in BIDS format
# Results can be written following most of the [qBIDS format recommandation](https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html)

subject_name = "sub_01_cs"
dir_path = "" # directory path where the files will be create
write_bids_MP2RAGE(d,subject_name,dir_path)
