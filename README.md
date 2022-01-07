# apache_arrow_32GB_write_feather
Directory used to test the following issue with apache arrow: https://github.com/apache/arrow/issues/11665

## Pre-requisits

This project makes use of R and RStudio. 

### R install using Homebrew

MacOS X (This requires installing xcode CLI)

```
xcode-select --install
```

Now you should be able to install R: 

```
brew install r
```

[RStudio](https://formulae.brew.sh/cask/rstudio) should be installable at this point:

```
brew install --cask rstudio
```

## Testing Scenarios

In an effort to better understand the issue we will test on a couple OSes with varying sets of resources. 

### MacBook 32GB RAM

The first test will verify functionality using a standard macbook development laptop. 

[Details can be found here](macos_12.1_32GB_RAM_1TB_nVME/README.md)

### Windows 10 64GB RAM

This tests the example R code with a 32GB dataframe on a laptop with 64GB of RAM. It tests both default windows Page File as well as a 64GB Page File configuration.

[Details can be found here](windows_10_20H2_64GB_RAM_1TB_nVME/README.md) 

### Windows 10 128GB RAM

This tests the example R code with a 32GB dataframe on a desktop with 128GB of RAM. It tests both default windows Page File as well as a 64GB Page File configuration.

[Details can be found here](windows_10_21H2_128GB_RAM_2TB_nVME/README.md) 