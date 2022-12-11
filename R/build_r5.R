Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-11.0.13/")
#.jinit()
options(java.parameters = "-Xmx80G")
library(r5r)

data_path <- "D:/OneDrive - University of Leeds/Data/r5r/great-britain-NTEM"

#download_r5()

r5r_core <- setup_r5(data_path = data_path,
                     verbose = TRUE,
                     use_elevation = TRUE)


dl <- readRDS("C:/Users/earmmor/Downloads/desire_lines_scotland.Rds")
summary(dl$dist_euclidean)
dl <- dl[dl$dist_euclidean < 30000, ]
dl <- dl[1:10000,]

fromPlace <- lwgeom::st_startpoint(dl)
toPlace <- lwgeom::st_endpoint(dl)

fromPlace <- st_as_sf(data.frame(id = seq(1, length(fromPlace)),
                                 geometry = fromPlace), crs = 4326)
toPlace <- st_as_sf(data.frame(id = seq(1, length(toPlace)),
                                 geometry = toPlace), crs = 4326)


fromPlace = fromPlace[fromPlace$id == "809",]
toPlace = toPlace[toPlace$id == "809",]

mode <- c('car')
max_trip_duration <- 60 # minutes
departure_datetime <- lubridate::ymd_hms("2021/10/28 08:00:00")

det <- detailed_itineraries(r5r_core = r5r_core,
                            origins = fromPlace,
                            destinations = toPlace,
                            mode = mode,
                            departure_datetime = departure_datetime,
                            shortest_path = FALSE,
                            progress = FALSE)

head(det)

library(tmap)
tmap_mode("view")
qtm(det)

stop_r5(r5r_core)
rJava::.jgc(R.gc = TRUE)

library(opentripplanner)
path_data = "D:/OneDrive - University of Leeds/Data/opentripplanner"
path_opt = "D:/OneDrive - University of Leeds/Data/opentripplanner/otp-1.5.0-shaded.jar"

log2 = otp_setup(path_opt,
                 path_data,
                 memory = 120011,
                 router = "great-britain-NTEM",
                 quiet = TRUE,
                 securePort = 8082, 
                 pointsets = TRUE,
                 analyst = TRUE,
                 open_browser = FALSE, )


otpcon <- otp_connect(router = "great-britain-NTEM")

routes2 <- otp_plan(otpcon, 
                   fromPlace = fromPlace,
                   toPlace = toPlace,
                   date_time = lubridate::ymd_hms("2021/10/28 08:00:00"),
                   mode = c("CAR"),
                   ncores = 30)
qtm(routes) +
  qtm(routes2, lines.col = "red") +
  qtm(det, lines.col = "blue")
otp_stop()

