#!/usr/bin/env Rscript

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)
# This script converts MS2 information to metfrag using a helper function
# Taking the command line arguments
args <- commandArgs(trailingOnly = TRUE)

if(length(args)==0)stop("No parameters are given!\n")

inputMS2<-NA
inputCamera<-NA
output<-NA
maxSpectra<-NA
minPeaks<-0
minPrecursorMass<-NA
maxPrecursorMass<-NA
precursortppm<-10
fragmentppm<-10
fragmentabs<-0.01
database<-"KEGG"
mode<-"pos"
adductRules<-"primary"
filetype<-NA
removeDup<-F
for(arg in args)
{
  argCase<-strsplit(x = arg,split = "=")[[1]][1]
  value<-strsplit(x = arg,split = "=")[[1]][2]

  if(argCase=="inputMS2")
  {
    inputMS2=as.character(value)

  }
  if(argCase=="inputCAMERA")
  {

    inputCamera=as.character(value)

  }
  if(argCase=="maxPrecursorMass")
  {

    maxPrecursorMass=as.numeric(value)

  }
  if(argCase=="minPrecursorMass")
  {

    minPrecursorMass=as.numeric(value)

  }
  if(argCase=="precursorppm")
  {

    precursortppm=as.numeric(value)

  }
  if(argCase=="fragmentppm")
  {

    fragmentppm=as.numeric(value)

  }

  if(argCase=="fragmentabs")
  {

    fragmentabs=as.numeric(value)

  }
  if(argCase=="database")
  {

    database=as.character(value)

  }
  if(argCase=="minPeaks")
  {

    minPeaks=as.numeric(value)

  }
  if(argCase=="maxSpectra")
  {

    maxSpectra=as.numeric(value)

  }
  if(argCase=="output")
  {
    output=as.character(value)
  }
  if(argCase=="mode")
  {
    mode=as.character(value)
  }
  if(argCase=="adductRules")
  {
    adductRules=as.character(value)
  }
  if(argCase=="filetype")
  {
    filetype=as.character(value)
  }
    if(argCase=="removeDup")
  {
    removeDup=as.logical(value)
  }

}

if(is.na(inputMS2) | is.na(inputCamera) | is.na(output)) stop("Both input (CAMERA and MS2) and output need to be specified!\n")

settingsObject<-list()
settingsObject[["DatabaseSearchRelativeMassDeviation"]]<-precursortppm
settingsObject[["FragmentPeakMatchAbsoluteMassDeviation"]]<-fragmentabs
settingsObject[["FragmentPeakMatchRelativeMassDeviation"]]<-fragmentppm
settingsObject[["MetFragDatabaseType"]]<-database
settingsObject[["MetFragScoreTypes"]]<-"FragmenterScore"
load(inputMS2)
MappedMS2s<-get(varNameForNextStep)
load(inputCamera)
cameraObject<-get(varNameForNextStep)


source("/usr/bin/adductCalculator.r")
source("/usr/bin/toMetfragCommand.r")

if(filetype=="zip")
{
directoryTMP<-"metfragTMP"
dir.create("metfragTMP", showWarnings = FALSE)


library(stringr)
toMetfragCommand(mappedMS2 = MappedMS2s$mapped,unmappedMS2 = MappedMS2s$unmapped,
                 cameraObject = cameraObject,searchMultipleChargeAdducts = T,includeUnmapped = F,
                 includeMapped = T,settingsObject = settingsObject,preprocess = F,savePath=directoryTMP, minPeaks=minPeaks,
		 maxSpectra=maxSpectra, maxPrecursorMass = maxPrecursorMass, minPrecursorMass = minPrecursorMass, mode = mode, primary = (adductRules == "primary"))

print(length(list.files("metfragTMP",full.names = TRUE)))

if(removeDup)
{

Files<-list.files(pattern = "txt",full.names=T)
FilesTMP<-sapply(strsplit(split = "_",fixed = T,x = basename(Files)),function(x){paste(x[-1],collapse = "_")})


FileDub<-Files[duplicated(FilesTMP)]

for(x in FileDub)
{
  file.remove(x)
}
}
zip::zip(zipfile="mappedtometfrag.zip",files=list.files(pattern="txt"))

res2<-file.copy(from ="mappedtometfrag.zip" ,to = paste(output,"/",mappedtometfrag.zip,sep=""),overwrite = T)
}
