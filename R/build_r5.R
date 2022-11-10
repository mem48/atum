Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-11.0.13/")
#.jinit()
options(java.parameters = "-Xmx80G")
library(r5r)

data_path <- "D:/OneDrive - University of Leeds/Data/r5r/great-britain-NTEM"

#download_r5()

r5r_core <- setup_r5(data_path = data_path,
                     verbose = TRUE,
                     use_elevation = TRUE)
