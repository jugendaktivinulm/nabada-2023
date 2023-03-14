#!/bin/bash

openscad -o - --export-format echo main.scad \
	| tr -d '"' \
	| grep '^ECHO: BOM' \
	| sed 's/^ECHO: BOM, //g' \
	| sort \
	| uniq -c
