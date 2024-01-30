library("RSQLite")

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="C:/Users/efluet/Dropbox/GCP_Stanford_Projects/data/OFST_db.sqlite")

## list all tables
tables <- dbListTables(con)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length=length(tables))

## create a data.frame for each table
for (i in seq(along=tables)) {
  lDataFrames[[i]] <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tables[[i]], "'", sep=""))
}





library(rgdal)

db_path <-"C:/Users/efluet/Dropbox/GCP_Stanford_Projects/data/OFST_db.sqlite"

ogrListLayers(db_path)


vectorImport <- readOGR(dsn=db_path, layer="kc_grid")



summary(vectorImport)

plot(vectorImport)
