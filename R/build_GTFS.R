# Build GTFS

# Bus
library(UK2GTFS)
path_bus <- "D:/OneDrive - University of Leeds/Data/UK2GTFS/TransXChange/data_20221102/S.zip"
cal = get_bank_holidays()
naptan = get_naptan()

gtfs_bus <- transxchange2gtfs(path_bus, 
                              ncores = 30, 
                              cal = cal,
                              naptan = naptan,
                              scotland = "yes")
gtfs_bus <- gtfs_merge(gtfs_bus, force = TRUE)

gtfs_write(gtfs_bus, 
           "D:/OneDrive - University of Leeds/Data/opentripplanner2/graphs/scotland-atum",
           name = "bus")

path_rail <- "D:/OneDrive - University of Leeds/Data/UK2GTFS/ATOC/timetable/2022-11-02/ttis536.zip"

gtfs_rail <- atoc2gtfs(path_rail, 
                              ncores = 30, transfers = FALSE)

# Warning message:
#   In atoc2gtfs(path_rail, ncores = 30) :
#   Adding 16 missing tiplocs, these may have unreliable location data

gtfs_write(gtfs_rail, 
           "D:/OneDrive - University of Leeds/Data/opentripplanner2/graphs/scotland-atum",
           name = "rail")
