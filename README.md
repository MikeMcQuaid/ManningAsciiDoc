# ManningAsciiDoc
ManningAsciiDoc is a Rake buildsystem for generating Manning DocBook and PDF
files from AsciiDoc.

## Features
- Outputs HTML5, Manning DocBook and PDF files from AsciiDoc source files.
- Generates whole book and individual chapter files.
- Validates all Manning DocBook files.
- Separates source content from outputted files.
- Uses an AsciiDoctor post-process filter plugin (rather than faffing with
  XSLT or regexes).
- Easily customisable.

## Status
ManningAsciiDoc currently generates valid Manning DocBook for my book [Git in
Practice](http://www.manning.com/mcquaid/?a_aid=MikeMcQuaid&a_bid=5688bbf4)
which makes use of prefaces, parts, notes, callouts and various other features.
It has been tested with varying AsciiDoc input but may need fixes for your book
([patches are welcome](https://github.com/mikemcquaid/ManningAsciiDoc/pulls)).

[![Build Status](https://travis-ci.org/mikemcquaid/ManningAsciiDoc.svg?branch=master)](https://travis-ci.org/mikemcquaid/ManningAsciiDoc)

## Usage
Ensure you have `ruby`, `git` and `libxml` installed on your system and setup
ManningAsciiDoc by running:
```bash
git clone git://github.com/mikemcquaid/ManningAsciiDoc.git
cd ManningAsciiDoc
gem list --installed --local bundler || gem install bundler
bundle install
```

If you wish to generate PDF files please contact Manning and obtain a copy of
`AAMakePDF` and download and extract it into the `AAMakePDF` directory (so
there should be a file named `./AAMakePDF/createPDF.sh`).

ManningAsciiDoc assumes that your book's source files a particular format. I've provided a sample repository for this at https://github.com/mikemcquaid/SampleManningAsciiDocBook.

You can see (and customize) the various assumptions that are made in the
[Rakefile](https://github.com/mikemcquaid/ManningAsciiDoc/blob/master/Rakefile).
 HTML5, whole book XML and PDF output rely on the preface/parts/chapters being
sorted by filename.

You can now generate the HTML5, Manning DocBook or PDF output with:
```bash
rake html5
rake docbook
rake pdf
```

This will output `book.html`, `book.xml` or `book.pdf` in the `./output/`
subdirectory (and copy all images under it).

I recommend you make `./input/` a separate (private) Git repository and
`./output/` a checkout of the Subversion directory you will use for submission
to Manning.

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
ManningAsciiDoc is licensed under the [MIT
License](http://en.wikipedia.org/wiki/MIT_License). The full license text is
available in
[LICENSE.txt](https://github.com/mikemcquaid/ManningAsciiDoc/blob/master/LICENSE
.txt).
