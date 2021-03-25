#!/bin/bash
## deploy
hexo clean && hexo generate && hexo deploy
# synchronization project
git checkout source && git add -A && git commit -am "Upload" && git push origin  source