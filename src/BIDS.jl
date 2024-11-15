export write_bids_MP2RAGE

"""
      write_bids_MP2RAGE(d::Dict,subname::AbstractString,folder="")

This function writes data from a dictionary (`d`) in BIDS (Brain Imaging Data Structure) format for MP2RAGE acquisitions.

**Arguments:**

* `d` (Dict): A dictionary containing the data to be written. Expected key-value pairs:
    * `im_reco` (Array): 5D array containing the reconstructed images (x,y,z,NR,TI)
    * `MP2RAGE` (Array): Combined MP2RAGE image data. (x,y,z,NR)
    * `T1map` (Array): Calculated T1 map from MP2RAGE images. (x,y,z,NR)
    * `params_prot` (Dict): Protocol parameters extracted from the Bruker file.
    * `params_MP2RAGE` (Struct): Dictionary containing MP2RAGE specific parameters.

* `subname` (AbstractString): The name of the subject.
* `folder` (AbstractString, optional): The folder where the BIDS data will be written. Defaults to the current directory.

**Functionality:**

1. Creates a directory structure for the anatomical data under `folder/subname/anat`.
2. Defines a list of file paths for different image types associated with MP2RAGE acquisitions.
3. Extracts relevant data from the dictionary `d` for each image type.
4. Creates NIfTI volumes (`NIVolume`) with the extracted data and specified voxel size from `d["params_prot"]`.
5. Writes each NIfTI volume to a compressed file (`.nii.gz`) in the corresponding directory.
6. Extracts acquisition parameters from `d`.
7. Creates a dictionary (`JSON_dict`) containing these parameters in BIDS format:
    * `InversionTime`: List of inversion times (TI1, TI2) in seconds.
    * `RepetitionTimeExcitation`: Repetition time (TR) in seconds.
    * `RepetitionTimePreparation`: MP2RAGE specific repetition time (MP2RAGE_TR) in seconds.
    * `NumberShots`: Echo train length (ETL).
    * `FlipAngle`: List of flip angles (alpha1, alpha2) in degrees.
    * `MagneticFieldStrength`: Magnetic field strength in Tesla.
    * `Units`: Units for the data (set to "arbitrary" in this case).
8. Writes the JSON dictionary to a file named `MP2RAGE.json` in the `folder/subname` directory.

**Note:** This function assumes the dictionary `d` contains the necessary data in the specified format. 
"""
function write_bids_MP2RAGE(d::Dict,subname::AbstractString,folder="")
  
  path_anat = joinpath(folder,subname,"anat")
  mkpath(path_anat)


  path_type = ["_inv-1-mag_MP2RAGE",
              "_inv-1-phase_MP2RAGE",
              "_inv-1-complex_MP2RAGE",
              "_inv-2-mag_MP2RAGE",
              "_inv-2-phase_MP2RAGE",
              "_inv-2-complex_MP2RAGE",
              "_UNIT1",
              "_T1map"]

  data_ = [ abs.(d["im_reco"][:,:,:,:,1]),
            angle.(d["im_reco"][:,:,:,:,1]),
            d["im_reco"][:,:,:,:,1],
            abs.(d["im_reco"][:,:,:,:,2]),
            angle.(d["im_reco"][:,:,:,:,2]),
            d["im_reco"][:,:,:,:,2],
            d["MP2RAGE"],
            d["T1map"]]

  voxel_size = tuple(parse.(Float64,d["params_prot"]["PVM_SpatResol"])...) #mm
  for (name,data) in zip(path_type, data_)
    ni = NIVolume(data,voxel_size=voxel_size)
    niwrite(joinpath(path_anat,subname*name*".nii.gz"),ni)
  end


  # pass parameters
  d["params_prot"]["ACQ_operator"] # required to read ACQ
  MagneticField = parse(Float64, d["params_prot"]["BF1"]) / 42.576
  p_MP2 = d["params_MP2RAGE"]

  # define JSON dict
  proj = Pkg.project()
  gen_dict = Dict{Any,Any}()
  gen_dict["Name"] = proj.name
  gen_dict["Version"] = string(proj.version)

  JSON_dict = Dict{Any,Any}()
  JSON_dict["InversonTime"]= [p_MP2.TI₁,p_MP2.TI₂] #s
  JSON_dict["RepetitionTimeExcitation"]= p_MP2.TR
  JSON_dict["RepetitionTimePreparation"]= p_MP2.MP2RAGE_TR
  JSON_dict["NumberShots"]= p_MP2.ETL
  JSON_dict["FlipAngle"]= [p_MP2.α₁,p_MP2.α₂]
  JSON_dict["MagneticFieldStrength"] = MagneticField
  JSON_dict["Units"] = "arbitrary"
  JSON_dict["GeneratedBy"]=gen_dict


  # Write the dictionary to a JSON file
  open(joinpath(folder,subname,"MP2RAGE.json"), "w") do f
    JSON.print(f, JSON_dict, 4)  # Indent 4 spaces for readability
  end

  # Write dataset description


  JSON_dict = Dict{Any,Any}()
  JSON_dict["generatedBy"] = proj.name
  JSON_dict["version"] = proj.version

end