# Symphony

Symphony is a MATLAB-based data acquisition system for electrophysiologists. It provides a framework for writing acquisition routines and a user interface to conduct experiments.

## Clone

`git clone https://github.com/Symphony-DAS/symphony-matlab2.git --recursive`

**Note:** You must use the `--recursive` option to recursively clone all submodules.

## Build

Matlab functions in the root directory are used to build the project. The scripts are named according to the build phase they execute. The phases include:

- `test`: run tests using the Matlab unit test framework
- `package`: package the project into a .mlappinstall file
- `install`: install the packaged product into Matlab

Similar to the [Maven Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), each phase will execute all phases before it (i.e. running `install` will execute `test`, `package`, `install`). In addition there is a `site` script to generate the project's documentation from the [wiki](https://github.com/Symphony-DAS/symphony-matlab2/wiki).

## Directory Structure

The project directory structure generally follows the [Maven Standard Directory Layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html).

## License

The MIT License (MIT)  
Copyright (c) 2016 Symphony-DAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
