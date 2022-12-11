# Clean OS Data an create DEM

#settings

folder.in = "D:/OneDrive - University of Leeds/Data/OS/Terrain50/terr50_gagg_gb_2022/data"
folder.out = "C:/dem"
folder.tmp = "C:/tmp"

# libs
library(stars)

files = list.files(folder.in, recursive = T, full.names = T)
dir.create(folder.tmp)
dir.create(folder.out)


for(i in 1:length(files)){
  message(paste0(Sys.time()," doing ",files[i]))
  
  # unzip and find the asc file
  unzip(files[i],exdir=folder.tmp)
  files.tmp = list.files(folder.tmp, full.names = T, pattern = ".asc")
  files.tmp = files.tmp[!grepl(".xml",files.tmp)]
  raster.name = sub(".asc","",files.tmp)
  raster.name = sub(paste0(folder.tmp,"/"),"",raster.name)
  r = read_stars(files.tmp)
  write_stars(r, paste0(folder.out,"/",raster.name,".tif"))
  file.remove(list.files(folder.tmp, full.names = T, recursive = T))
}


files = list.files(folder.out, pattern = ".tif", full.names = T)
moz2 = st_mosaic(files)
moz3 = read_stars(moz2)

moz4 = st_transform(moz3, 4326)

write_stars(moz3, "D:/OneDrive - University of Leeds/Data/opentripplanner2/graphs/scotland-atum/UK_DEM_27700.tif")



# make master raster
rasterOptions(tmpdir="F:/tmp")
rasterOptions(chunksize=1e+08)
rasterOptions(maxmemory=1e+10)
rasterlist$filename <- "F:/dem/national4.tif"
rasterlist$overwrite <- TRUE
merged <- do.call(merge, rasterlist)

#writeRaster(merged3,filename = "F:/otp2/graphs/current/gbDEM.tif", overwrite=TRUE)
#crs(merged3)
newproj = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
merges.proj = projectRaster(merged, crs=newproj)
writeRaster(merges.proj,filename = "F:/otp2/graphs/current/gbDEM.tif", overwrite=TRUE)