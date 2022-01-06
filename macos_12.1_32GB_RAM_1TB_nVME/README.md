# MacOS X 12.1 (Monterey)

This is a standard Macbook laptop with 32GB of RAM and 1TB of nVME disk available. *important* as the testing makes extensive us of SWAP!

## Usage

We are going to run the script `../src/test_32GB_write_feather.R` in RStudio. Ideally this should be done via command line for any automated testing. 

## SessionInfo

```
> sessionInfo()
R version 4.1.2 (2021-11-01)
Platform: x86_64-apple-darwin17.0 (64-bit)
Running under: macOS Monterey 12.1

Matrix products: default
LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
 [1] tidyselect_1.1.1  bit_4.0.4         compiler_4.1.2    magrittr_2.0.1    assertthat_0.2.1 
 [6] R6_2.5.1          tools_4.1.2       glue_1.6.0        rstudioapi_0.13   bit64_4.0.5      
[11] vctrs_0.3.8       data.table_1.14.2 arrow_6.0.1       rlang_0.4.12      purrr_0.3.4  
```

## memory.limi()

```
> memory.limit()
[1] Inf
Warning message:
'memory.limit()' is Windows-specific 
```

## Run 1

The first run has no files created and was done after a reboot so RAM and SWP are nice and clean. 

PRE:     06GB RAM,  00GB SWP, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  16GB RAM,  04GB SWP, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 16GB RAM,  21GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather
POST:    16GB RAM, 0.5GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather

When writing the feather file, 20+GB of SWP was allocated =*( good thing we hvae an nVME drive. 

## run 2 

The second run was done after a reboot of the OS to clear out RAM and SWP to make sure the completion wasn't just a fluke. Also to compare created file sizes. 

PRE:     06GB RAM,  00GB SWP, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  16GB RAM,  04GB SWP, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 14GB RAM,  32GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather
POST:    16GB RAM, 0.7GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather

## file output size compare

Both runs seem to have created files of the exact same size. 

```
❯ ls -al
total 244511432
drwxr-xr-x   7 rockhowse  staff          224 Jan  6 11:08 .
drwxr-xr-x  12 rockhowse  staff          384 Jan  6 10:54 ..
-rw-r--r--   1 rockhowse  staff           32 Jan  6 09:49 .gitignore
-rw-r--r--   1 rockhowse  staff  46800002292 Jan  6 11:05 fakeFile.csv
-rw-r--r--   1 rockhowse  staff  46800002292 Jan  6 10:39 fakeFile.csv.001
-rw-r--r--   1 rockhowse  staff  15785280458 Jan  6 11:10 fakeFile.feather
-rw-r--r--   1 rockhowse  staff  15785280458 Jan  6 10:44 fakeFile.feather.001
```