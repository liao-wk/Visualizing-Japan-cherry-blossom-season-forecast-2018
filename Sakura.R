library(geojsonio)
library(ggplot2)
library(dplyr)
library(tidyr)

#Step 1 - Load clean dataset
mydates = unique(df_dummy$date)

#Step 2 - Generate 55 images

#Step 3 - Create a movie from the images (please note that ffmeg is on my C:/)
makemovie_cmd <- paste0("C:/ffmpeg/bin/ffmpeg -framerate 5 -y -i ", paste0(getwd(), "/maps/img_%7d.png"),  " -r 56 -pix_fmt yuv420p ",  paste0(getwd(), "/maps/"), "movie.mp4")
system(makemovie_cmd)
