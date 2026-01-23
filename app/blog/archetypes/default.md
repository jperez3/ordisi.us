+++
author= "Joe"
authorAvatarPath= "/avatar.jpeg"
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
summary = "someting"
description = "someting"
toc = true
readTime = true
autonumber = true
math = true
tags = ["one", "two"]
+++
