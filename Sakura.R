library(geojsonio)
library(ggplot2)
library(dplyr)
library(tidyr)

#Step 1 - Load clean dataset
myurl<-'https://raw.githubusercontent.com/tristanga/Visualizing-Japan-cherry-blossom-season-forecast-2018/master/sakura_2018.csv'
sakuradf<- read.csv(myurl)
sakuradf$sakura <- as.factor(sakuradf$sakura)

#Load geojson Japan map and convert it into dataframe
myurl <- 'https://raw.githubusercontent.com/tristanga/Visualizing-Japan-cherry-blossom-season-forecast-2018/master/Japan.json'
map_japan <- geojson_read(myurl,  what = "sp")
map_japan.df <- fortify(map_japan)

#Add the name to the region
myid <- as.data.frame(map_japan@data)
myid$id <- seq.int(nrow(myid))-1
myid <- myid  %>% select(id, name)
map_japan.df <- merge(map_japan.df, myid,  by.x="id", by.y="id")

#Step 2 - Generate 55 images

#Create a filter of all the dates
mydates =unique(sakuradf$date)

#Display only the last 55 days of the season (skipping Okinawa region)
startdate = 65
enddate = length(mydates)

#Generate a style
theme_map <- function(base_size = 12) {
  theme_minimal() +
    theme(
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.major = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "#f5f5f2", color = NA), 
      panel.background = element_rect(fill = "#f5f5f2", color = NA), 
      legend.position = 'None', legend.title = element_blank(),
      panel.border = element_blank()
    )
}

#Create a loop to filter on each day, generate a chart and save 55 images 
for (x in startdate:enddate){
  my_x = mydates[x]
  print(paste("The year is", my_x))
  sakuradf_x <- sakuradf %>% filter(date == my_x)
  map_japan.df_x <- merge(map_japan.df, sakuradf_x,  by.x="name", by.y="name")
  japanplot <- ggplot(map_japan.df_x) +
    geom_polygon(aes(x = long, y = lat, fill = sakura, group = group)) +
    theme_map()+scale_fill_manual(values=c("4"='#d2618c',"3"='#e3adcb' , "2"="#f7e0f4", "1"="#9db6c7")) +
    ylim(30,46)+ 
    xlim(127,148)+ 
    labs(x = NULL, 
         y = NULL, 
         title = "Japan Sakura Seasons", 
         subtitle = paste("Date: ", my_x, sep=""),
         caption = "Japan Weather Forecast 2018")
  filename <- paste0("maps/img_" , str_pad(x-64, 7, pad = "0"),  ".png")
  ggsave(filename = filename, plot = japanplot, width = 5, height = 5, dpi = 150, type = "cairo-png")
}

#Step 3 - Create a movie from the images (please note that ffmeg is on my C:/)
makemovie_cmd <- paste0("C:/ffmpeg/bin/ffmpeg -framerate 5 -y -i ", paste0(getwd(), "/maps/img_%7d.png"),  " -r 56 -pix_fmt yuv420p ",  paste0(getwd(), "/maps/"), "sakura_movie.mp4")
system(makemovie_cmd)
