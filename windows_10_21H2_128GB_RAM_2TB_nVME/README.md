# Windows 10 Home 20H2 (19042.1415)

A custom build gameing machine with 11th gen Intel processor and 128GB of DDR4 RAM. 

## Usage

We are going to run the script `../src/test_32GB_write_feather.R` in RStudio. Ideally this should be done via command line for any automated testing. 

## SessionInfo

```
> sessionInfo()
R version 4.1.2 (2021-11-01)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19044)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252  LC_CTYPE=English_United States.1252   
[3] LC_MONETARY=English_United States.1252 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
 [1] tidyselect_1.1.1  bit_4.0.4         compiler_4.1.2    magrittr_2.0.1    assertthat_0.2.1 
 [6] R6_2.5.1          tools_4.1.2       glue_1.6.0        rstudioapi_0.13   bit64_4.0.5      
[11] vctrs_0.3.8       data.table_1.14.2 arrow_6.0.1       rlang_0.4.12      purrr_0.3.4      
```

## memory.limit()

```
> memory.limit()
[1] 130897
```

## Run 1

The first run starts with an empty tmp directory and was done after a reboot so RAM and PageFile are nice and clean. It's using the default windows Page File setting which allows windows to auto-configure it. Usually decent, but in this case it doesn't know how to handle the large desire for a ton of virtual memory. 

Interestingly enough... this first run actually ran into the hanging problem! Even with 128GB of RAM and 18GB of PageFile.

1. No CPU usage
2. No Disk usage
3. RStudio "hangs" (doesn't error out)
4. When RStudio is terminated, the resulting file buffer flushed to disk is a "random" size 

PRE:     009GB RAM,  18GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~??GB fakeFile.feather <--- hangs
POST:    128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~03GB fakeFile.feather <--- flushes out ??? bytes

I was forced to kill RStudio, and after doing so, it appears that windows flushed out some amount of data from the process to disk. In this case ~3GB

## Run 2

The second run was done using the same setup above to see if there were any inconsistencies between runs. 

PRE:     008GB RAM,  18GB PF, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  128GB RAM,  18GB PF, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 128GB RAM,  18GB PF, ~44GB fakeFile.csv, ~15GB fakeFile.feather
POST:    056GB RAM,  18GB PF, ~44GB fakeFile.csv, ~15GB fakeFile.feather

The second run completed without issue and generated the roughly ~14GB feather file as expected. 

## run 3 

The third one was done after a reboot to see if there were any languishing issues with the file generation. 

This one hung as well and again gets into the following state.

1. No CPU usage
2. No Disk usage
3. RStudio "hangs" (doesn't error out)
4. When RStudio is terminated, the resulting file buffer flushed to disk is a "random" size 

PRE:     009GB RAM,  18GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~??GB fakeFile.feather <--- hangs
POST:    128GB RAM,  18GB PF, ~44GB fakeFile.csv,  ~12GB fakeFile.feather <--- flushes out ??? bytes

I was forced to kill RStudio, and after doing so, it appears that windows flushed out some amount of data from the process to disk. In this case ~12GB


## run 4

Given the sporadic behavior outlined above even with 128GB of RAM... let's try bumping the Page File to 64GB and see if we get any different results. 

This one appeared to work as expected

PRE:     009GB RAM,  64GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  128GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 128GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~15GB fakeFile.feather
POST:    056GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~15GB fakeFile.feather 

It produced the expected ~14GB feather file with no issues.

## run 5

Ok we got one working, let's try another to see if it's being just as flakey.

This one appeared to work as expected

PRE:     009GB RAM,  64GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  128GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 128GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~15GB fakeFile.feather
POST:    056GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~15GB fakeFile.feather 

It produced the expected ~14GB feather file with no issues.


## run 6

Third try was not the charm it would seem. Even with 128GB of RAM and 64GB Page File. It still hung.

PRE:     009GB RAM,  64GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  128GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 112GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~06GB fakeFile.feather <--- hangs
POST:    056GB RAM,  64GB PF, ~44GB fakeFile.csv,  ~06GB fakeFile.feather <--- flushes out ??? bytes

Boo, time to fire up the old debugger.


## file output size compare

While the 128GB + 64GB Page File kind of worked, still not consistent. Definately need to do some debugging to go further. 

```
rockhowse@DESKTOP-01V46O9:/mnt/c/Projects/vdl/apache_arrow_32GB_write_feather/tmp$ ls -al
total 283553460
drwxrwxrwx 1 rockhowse rockhowse        4096 Jan  7 05:02 .
drwxrwxrwx 1 rockhowse rockhowse        4096 Jan  7 05:06 ..
-rwxrwxrwx 1 rockhowse rockhowse          32 Jan  7 04:06 .gitignore
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  7 05:01 fakeFile.csv
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  7 04:14 fakeFile.csv.001
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  7 04:20 fakeFile.csv.002
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  7 04:46 fakeFile.csv.004
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  7 04:51 fakeFile.csv.005
-rwxrwxrwx 1 rockhowse rockhowse  6326386832 Jan  7 05:02 fakeFile.feather
-rwxrwxrwx 1 rockhowse rockhowse  2546478192 Jan  7 04:14 fakeFile.feather.001
-rwxrwxrwx 1 rockhowse rockhowse 15785280458 Jan  7 04:21 fakeFile.feather.002
-rwxrwxrwx 1 rockhowse rockhowse 15785280458 Jan  7 04:47 fakeFile.feather.004
-rwxrwxrwx 1 rockhowse rockhowse 15785280458 Jan  7 04:53 fakeFile.feather.005
```