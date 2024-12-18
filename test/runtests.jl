using SEQ_BRUKER_a_MP2RAGE_CS_360
using Test
using LazyArtifacts
using SEQ_BRUKER_a_MP2RAGE_CS_360.NIfTI
using SEQ_BRUKER_a_MP2RAGE_CS_360.JSON
using Pkg
using Artifacts

toml = Artifacts.find_artifacts_toml(@__DIR__)


const datadir = Pkg.Artifacts.ensure_artifact_installed("MP2RAGE_data", toml)
@info "The test data is located at $datadir."

@testset "SEQ_BRUKER_a_MP2RAGE_CS_360.jl" begin

    path_bruker = joinpath(datadir, "MP2RAGE_FULLY")
    d = reconstruction_MP2RAGE(path_bruker; mean_NR=true)

    @test size(d["im_reco"]) == (128,128,96,1,2)
    @test size(d["T1map"]) == (128,128,96,1)
    
    write_bids_MP2RAGE(d,"sub","")

    ni = niread(joinpath("sub","anat","sub_T1map.nii.gz")).raw
    @test d["T1map"] == ni

    JSON_dict = JSON.parsefile(joinpath("sub","MP2RAGE.json"))
    @test JSON_dict["RepetitionTimePreparation"] == 5000
end
