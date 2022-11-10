library(sf)
library(tmap)
library(opentripplanner)
library(dplyr)
library(stplanr)
tmap_mode("view")



path_data = "D:/OneDrive - University of Leeds/Data/opentripplanner"
path_opt = "D:/OneDrive - University of Leeds/Data/opentripplanner/otp-1.5.0-shaded.jar"

log2 = otp_setup(path_opt,
                 path_data,
                 router = "great-britain-NTEM",
                 port = 8091,
                 securePort = 8092,
                 analyst = TRUE,
                 memory = 80000,
                 quiet = FALSE,
                 wait = FALSE)

otpcon <- otp_connect(router = "great-britain-NTEM", port = 8091)

dl <- readRDS("C:/Users/earmmor/Downloads/desire_lines_scotland.Rds")
summary(dl$dist_euclidean)
dl <- dl[dl$dist_euclidean < 30000, ]

fromPlace <- lwgeom::st_startpoint(dl)
toPlace <- lwgeom::st_endpoint(dl)

fromPlace <- st_as_sf(data.frame(id = dl$geo_code1, geometry = fromPlace))
toPlace <- st_as_sf(data.frame(id = dl$geo_code2, geometry = toPlace))

summary(st_is_valid(fromPlace))
summary(st_is_valid(toPlace))

routes_part <- otp_plan(otpcon,
                        fromPlace = fromPlace,
                        toPlace = toPlace,
                        fromID = fromPlace$id,
                        toID = toPlace$id,
                        mode = c("BICYCLE"),
                        ncores = 1,
                        distance_balance = FALSE)






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
