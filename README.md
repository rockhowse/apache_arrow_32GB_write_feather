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