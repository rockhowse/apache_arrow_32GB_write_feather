# set the wd to the ./tmp directory
# set the wd to be where this script is saved
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# set dimensions based on the real file
numRows = 26e6 # 26M rows in the real file
numCols = 150 # 150 columns in the real file

# whip up a fake dataframe
fakeDataframe <- as.data.frame(matrix("fake string", numRows, numCols))

# change the column names for aesthetic purposes, I guess
names(fakeDataframe) <- sprintf("Fake Column %s", 1:150)

# save the fake file with data.table
data.table::fwrite(fakeDataframe, "../tmp/fakeFile.csv")

# save the fake file with arrow
arrow::write_feather(fakeDataframe, "../tmp/fakeFile.feather")