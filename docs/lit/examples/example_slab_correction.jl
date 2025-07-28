#---------------------------------------------------------
# # [Slab correction](@id 03-slab-correction)
#---------------------------------------------------------

# ## Description
# 
# This example describes how to correct the slab profile excitation produced by a non-ideal excitation RF pulse.
#

# ## Loading Package
using LazyArtifacts # loading data
using SEQ_BRUKER_a_MP2RAGE_CS_360
using CairoMakie # plotting

# ## Download the datasets
# If you run the literate example offline, run the following line: `MP2_artifacts = artifact"MP2RAGE_data"`
datadir = Main.MP2_artifacts

@info "The test data is located at $datadir."

# If you want to perform your own reconstruction, you can change the following line to point to another Bruker dataset.
path_sinc = joinpath(datadir, "sinc10H")
path_hermite = joinpath(datadir, "hermite")

# ## Perform the standard reconstruction 
# First, let's reconstruct two acquisitions performed on the same animal: one with a sinc10H excitation pulse and the second with a hermite pulse.

d_hermite = reconstruction_MP2RAGE(path_hermite; mean_NR=true)
d_sinc = reconstruction_MP2RAGE(path_sinc; mean_NR=true)

begin
  sl = 48
  f = Figure(size=(600,200))
  ax=Axis(f[1,1],title="sinc10H")
  h=heatmap!(ax,d_sinc["MP2RAGE"][:,sl,:,1],colormap=:grays)
  arrows2d!(ax,(48,85),(20,0),color=:red)

  ax=Axis(f[1,2],title="hermite")
  h=heatmap!(ax,d_hermite["MP2RAGE"][:,sl,:,1],colormap=:grays)
  arrows2d!(ax,(48,85),(20,0),color=:red)

  ax=Axis(f[1,3],title="diff")
  h=heatmap!(ax,(d_sinc["MP2RAGE"] .- d_hermite["MP2RAGE"])[:,sl,:,1],colormap=:grays,colorrange = (-0.1,0.1))
  arrows2d!(ax,(48,85),(20,0),color=:red)
  arrows2d!(ax,(48,15),(20,0),color=:green)

  for ax in f.content   # hide decoration befor adding colorbar
    hidedecorations!(ax)
  end
  Colorbar(f[1,4],h,)
  f
end
# You can observe signal inhomogeneity along the top-to-bottom axis.
# This is especially visible in the difference between the two images.
# The pattern is visible at the top (red arrow) and at the bottom (green arrow).

# ## Artefact explanation : slab excitation profile
# This artifact can be explained by the slab excitation profile of the RF pulse.
# In the next figure, we show the effective angle of excitation along the slice orientation (corresponding to the Y axis in the previous figure).

using SEQ_BRUKER_a_MP2RAGE_CS_360.MRIFiles
profile_sinc = extract_slab_profile(BrukerFile(path_sinc))
profile_hermite= extract_slab_profile(BrukerFile(path_hermite))

begin
  f = Figure(size=(500,400))
  ax=Axis(f[1,1],title="sinc10H",xlabel="partition position", ylabel="Effective angle (degrees)")
  ax.xticks=[1,8,25,50,75,89,96]
  lines!(ax,profile_sinc)
  vlines!(ax,8,color=:green,linestyle=:dash)
  vlines!(ax,96-8+1,color=:green,linestyle=:dash)

  hlines!(ax,7,color=:red,linestyle=:dash)
  ax=Axis(f[2,1],title="hermite",xlabel="partition position", ylabel="Effective angle (degrees)")
  ax.xticks=[1,25,50,75,96]
  lines!(ax,profile_hermite)
  hlines!(ax,7,color=:red,linestyle=:dash)

  f
end

# As you can see, the sinc10H reaches the expected angle of 7 degrees after 8 partitions/voxels, but in the hermite case, we observe a large oscillation.
# This effect creates the differences in the MP2RAGE image.

# ## Correction of the slab profile

# Knowing the shape of the RF pulse, we are able to correct this effect when computing the T1 maps from the MP2RAGE images.
# To do so, for each position along the partition, we generate a different lookup table with the correct effective angle and compute the T1 map for this partition.
# To enable slab correction, you can pass the keyword `slab_correction=true`.

d_hermite_corr = reconstruction_MP2RAGE(path_hermite; mean_NR=true, slab_correction = true)
d_sinc_corr = reconstruction_MP2RAGE(path_sinc; mean_NR=true, slab_correction = true)

begin
  T1range = (1000,2000)
  using QMRIColors
  cmap,imClip_sinc = relaxationColorMap("T1",d_sinc["T1map"][:,sl,:,1],T1range[1],T1range[2])
  cmap,imClip_hermite = relaxationColorMap("T1",d_hermite["T1map"][:,sl,:,1],T1range[1],T1range[2])
  cmap,imClip_sinc_corr = relaxationColorMap("T1",d_sinc_corr["T1map"][:,sl,:,1],T1range[1],T1range[2])
  cmap,imClip_hermite_corr = relaxationColorMap("T1",d_hermite_corr["T1map"][:,sl,:,1],T1range[1],T1range[2])

  f = Figure(size=(600,400))

  ax=Axis(f[1,1],title="sinc10H")
  h=heatmap!(ax,imClip_sinc,colorrange = T1range, colormap=cmap)

  ax=Axis(f[1,2],title="hermite")
  h=heatmap!(ax,imClip_hermite,colorrange = T1range, colormap=cmap)
  arrows2d!(ax,(48,85),(20,0),color=:red)

  ax=Axis(f[2,1],title="sinc10H")
  h=heatmap!(ax,imClip_sinc_corr,colorrange = T1range, colormap=cmap)

  ax=Axis(f[2,2],title="hermite")
  hT1=heatmap!(ax,imClip_hermite_corr,colorrange = T1range, colormap=cmap)

  ax=Axis(f[1,4],title="diff")
  h=heatmap!(ax,d_sinc["T1map"][:,sl,:,1]-d_hermite["T1map"][:,sl,:,1],colormap=:grays,colorrange=(-100,100))

  ax=Axis(f[2,4],title="diff corrected")
  h=heatmap!(ax,d_sinc_corr["T1map"][:,sl,:,1]-d_hermite_corr["T1map"][:,sl,:,1],colormap=:grays,colorrange=(-100,100))

  for ax in f.content   # hide decoration befor adding colorbar
    hidedecorations!(ax)
  end
  Colorbar(f[:,3],hT1,label = "T₁ [ms]", flip_vertical_label=true)
  Colorbar(f[:,5],h,label = "ΔT₁ [ms]", flip_vertical_label=true)

  Label(f[1,-1], "Initial", rotation = pi/2)
  Label(f[2,-1], "Corrected", rotation = pi/2)

  rowsize!(f.layout,1,100)
  rowsize!(f.layout,2,100)
  colgap!(f.layout,1,0)
  colsize!(f.layout,0,0)
  f
end

# The MP2RAGE images are also corrected during this process. They are computed from the corrected T1 map using the expected flip angles.

begin
  T1range = (-0.5,0.5)
  f = Figure(size=(600,400))

  ax=Axis(f[1,1],title="sinc10H")
  h=heatmap!(ax,d_sinc["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange = T1range)

  ax=Axis(f[1,2],title="hermite")
  h=heatmap!(ax,d_hermite["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange = T1range)
  arrows2d!(ax,(48,85),(20,0),color=:red)

  ax=Axis(f[2,1],title="sinc10H")
  h=heatmap!(ax,d_sinc_corr["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange = T1range)

  ax=Axis(f[2,2],title="hermite")
  hT1=heatmap!(ax,d_hermite_corr["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange = T1range)

  ax=Axis(f[1,4],title="diff")
  h=heatmap!(ax,d_sinc["MP2RAGE"][:,sl,:,1]-d_hermite["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange=(-0.1,0.1))

  ax=Axis(f[2,4],title="diff corrected")
  h=heatmap!(ax,d_sinc_corr["MP2RAGE"][:,sl,:,1]-d_hermite_corr["MP2RAGE"][:,sl,:,1],colormap=:grays,colorrange=(-0.1,0.1))

  for ax in f.content   # hide decoration befor adding colorbar
    hidedecorations!(ax)
  end
  Colorbar(f[1:2,3],hT1,label = "MP2RAGE [ms]", flip_vertical_label=true)
  Colorbar(f[1:2,5],h,label = "Δ MP2RAGE [ms]", flip_vertical_label=true)

  Label(f[1,-1], "Initial", rotation = pi/2)
  Label(f[2,-1], "Corrected", rotation = pi/2)

  rowsize!(f.layout,1,100)
  rowsize!(f.layout,2,100)
  colgap!(f.layout,1,0)
  colsize!(f.layout,0,0)
  f
end

# Unfortunately, the correction can't be applied to TI1 and TI2 because proton density ρ, T₂*, and B₁- effects are not known.