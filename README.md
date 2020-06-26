# HTgnss

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://htyeim.github.io/HTgnss.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://htyeim.github.io/HTgnss.jl/dev)
[![Build Status](https://travis-ci.com/htyeim/HTgnss.jl.svg?branch=master)](https://travis-ci.com/htyeim/HTgnss.jl)
[![Codecov](https://codecov.io/gh/htyeim/HTgnss.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/htyeim/HTgnss.jl)


Read Rinex files, mostly based on GPSTk.

## install 
```
]
add https://github.com/htyeim/HTrg.jl
add https://github.com/htyeim/HTgnss.jl
```

## example

```
import HTgnss
@time iobs = HTgnss.load_obs("path_to_obs_file");
@time inav = HTgnss.load_nav("path_to_nav_file");


```

