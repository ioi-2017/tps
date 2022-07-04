#!/bin/bash

problem="__TPARAM_SHORT_NAME__"
memory=1000

java -XX:+UseSerialGC -Xbatch -XX:-TieredCompilation -XX:CICompilerCount=1 -Xmx${memory}M -Xss${memory}M -jar "${problem}.jar"
