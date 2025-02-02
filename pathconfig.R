# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- rprojroot::find_rstudio_root_file()

# Main directories
datapath     <- file.path(basepath, "data")
interwrk    <- file.path(datapath,"interwrk")
crossrefloc <- file.path(datapath,"crossref")
openalexloc <- file.path(datapath,"openalex")
auxilloc    <- file.path(datapath,"auxiliary")
jiraconf    <- file.path(datapath,"confidential")
Outputs	    <- file.path(basepath,"outputs")
# for local processing
jiraanon <- file.path(basepath,"data","anon")
jirameta <- file.path(basepath,"data","metadata")


programs <- file.path(basepath,"programs")

for ( dir in list(datapath,interwrk,crossrefloc,openalexloc,jiraconf,jiraanon,jirameta,Outputs)){
	if (file.exists(dir)){
	} else {
	dir.create(file.path(dir))
	}
}
