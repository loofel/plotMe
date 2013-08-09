plotMe
======

Matlab PostProcessing Tool

Currently the use of latex as interpreter requires the following packages (*.sty files):
- siunitx and it's dependencies (l3kernel, l3packages,amstext,array,xspace,translate,xparse)
- tudfonts

Please set the path to those packages in localGetTeXPath  inside the tex.m 

Furthermore change the relative path to the mwarticle.cls file in localDecorateInputString inside tex.m


