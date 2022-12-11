
library(opentripplanner)

otp_dl_jar(path = "D:/OneDrive - University of Leeds/Data/opentripplanner2", version = "2.1.0", cache = FALSE)

path_otp = "D:/OneDrive - University of Leeds/Data/opentripplanner2/otp-2.1.0-shaded.jar"
path_data = "D:/OneDrive - University of Leeds/Data/opentripplanner2"


#C:\Program Files\Amazon Corretto\jdk1.8.0_212\bin
#C:\Program Files (x86)\Amazon Corretto\jdk1.8.0_212\bin
#C:\Program Files\Common Files\Oracle\Java\javapath
#C:\Program Files (x86)\Common Files\Oracle\Java\javapath
#C:\Program Files\Java\jdk-11.0.13\


otp_check_java(2)

otp_build_graph(path_otp, path_data, memory = 80000, router = "scotland-atum", otp_version = 2, quiet = FALSE)

otp_setup(path_otp, path_data, memory = 80000, router = "scotland-atum", 
          port = 8091,
          securePort = 8092,otp_version = 2, quiet = FALSE )
