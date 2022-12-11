library(sf)
library(tmap)
library(opentripplanner)
library(dplyr)
library(stplanr)
tmap_mode("view")



path_data = "D:/OneDrive - University of Leeds/Data/opentripplanner"
path_opt = "D:/OneDrive - University of Leeds/Data/opentripplanner/otp-1.5.0-shaded.jar"

# log2 = otp_setup(path_opt,
#                  path_data,
#                  router = "great-britain-NTEM",
#                  port = 8091,
#                  securePort = 8092,
#                  analyst = TRUE,
#                  memory = 80000,
#                  quiet = FALSE,
#                  wait = FALSE)

otpcon <- otp_connect(router = "default", port = 8091, otp_version = 2)
otpcon$otp_version <- 2

dl <- readRDS("C:/Users/earmmor/Downloads/desire_lines_scotland.Rds")
summary(dl$dist_euclidean)
dl <- dl[dl$dist_euclidean < 30000, ]

fromPlace <- lwgeom::st_startpoint(dl)
toPlace <- lwgeom::st_endpoint(dl)

fromPlace <- st_as_sf(data.frame(id = dl$geo_code1, geometry = fromPlace))
toPlace <- st_as_sf(data.frame(id = dl$geo_code2, geometry = toPlace))

summary(st_is_valid(fromPlace))
summary(st_is_valid(toPlace))

fromPlace = fromPlace[1:10000,]
toPlace = toPlace[1:10000,]


message(Sys.time())
routes_part <- otp_plan(otpcon,
                        fromPlace = fromPlace,
                        toPlace = toPlace,
                        fromID = fromPlace$id,
                        toID = toPlace$id,
                        mode = c("BICYCLE"),
                        ncores = 44,
                        distance_balance = TRUE)

requuests <- data.frame(fromPlace = fromPlace$id, toPlace = toPlace$id)
requuests <- dplyr::left_join(requuests, routes_part, by = c("fromPlace", "toPlace"))

req_missing <- requuests[is.na(requuests$duration),]
req_missing <- req_missing[,1:2]
req_missing <- req_missing[req_missing$fromPlace != req_missing$toPlace,]

req_missing <- dplyr::left_join(req_missing, dl, by = c("fromPlace" = "geo_code1", "toPlace" = "geo_code2"))
req_missing <- st_as_sf(req_missing)

message(Sys.time())

routes_part <- otp_plan(otpcon,
                        fromPlace = fromPlace[1:10,],
                        toPlace = toPlace[1:10,],
                        mode = c("BICYCLE"),
                        ncores = 44)


toPlace <- toPlace[1:100,]
fromPlace <- fromPlace[1:100,]

routes_tst <- otp_plan(otpcon,
                        fromPlace = fromPlace,
                        toPlace = toPlace,
                        fromID = fromPlace$id,
                        toID = toPlace$id,
                        mode = c("BICYCLE"),
                        ncores = 44,
                        distance_balance = TRUE)



qtm(routes_part)

saveRDS(routes_part, "travel2work_routes.Rds")

routes <- routes_part[,c("fromPlace","toPlace","duration","elevationLost","elevationGained","distance")]

routes <- left_join(st_drop_geometry(dl), routes, by = c("geo_code1" = "fromPlace",
                                                         "geo_code2" = "toPlace"))
routes <- st_as_sf(routes)
routes <- routes[!st_is_empty(routes),]

rnet <- overline2(routes, attrib = c("bicycle","all"), ncores = 30)

st_write(rnet, "rnet_2011.geojson")
st_write(rnet[rnet$bicycle > 50,], "rnet_2011_med.geojson")
st_write(rnet[rnet$bicycle > 500,], "rnet_2011_low.geojson")
